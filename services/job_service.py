import re
import json
from data.repository import JobRepository
from models.job import Job


class JobService:
    def __init__(self, db_path):
        self.repository = JobRepository(db_path)

    def _parse_jobs_from_raw(self, raw_text):
        raw_text = (raw_text or "").strip()
        if not raw_text:
            return []

        def try_json(txt):
            try:
                return json.loads(txt)
            except Exception:
                return None

        obj = try_json(raw_text)

        if obj is None and "\n" in raw_text:
            jobs = []
            for line in raw_text.splitlines():
                line = line.strip()
                if not line:
                    continue
                o2 = try_json(line)
                if o2 is not None:
                    self._walk_collect_jobs(o2, jobs)
            if jobs:
                return jobs

        if obj is not None:
            jobs = []
            self._walk_collect_jobs(obj, jobs)
            if jobs:
                return jobs

        def rx(pattern, text, flags=re.I):
            m = re.search(pattern, text, flags)
            return m.group(1) if m else None

        state = rx(r'\bstate\s*:\s*"([^"]+)"', raw_text) or rx(r'\bstate\s*:\s*([A-Za-z_]+)', raw_text)
        status_code = rx(r'\bstatus\s*:\s*"([^"]+)"', raw_text) or rx(r'\bstatus\s*:\s*([0-9A-Za-z_]+)', raw_text)
        job_id = rx(r'\bjobid\s*:\s*"([^"]+)"', raw_text) or rx(r'\bjobid\s*:\s*([0-9]+)', raw_text)
        client = rx(r'\bclient(?:name)?\s*:\s*"([^"]+)"', raw_text) or rx(r'\bclient(?:name)?\s*:\s*([^,\}\s]+)',
                                                                          raw_text)
        policy = rx(r'\bpolicy(?:name)?\s*:\s*"([^"]+)"', raw_text) or rx(r'\bpolicy(?:name)?\s*:\s*([^,\}\s]+)',
                                                                          raw_text)
        start_time = rx(r'\bstart(?:Time|_time)\s*:\s*"([^"]+)"', raw_text) or rx(
            r'\bstart(?:Time|_time)\s*:\s*([^,\}\s]+)', raw_text)

        return [Job(job_id, state, status_code, client, policy, start_time)]

    def _walk_collect_jobs(self, obj, out_list):
        if isinstance(obj, dict):
            kl = {k.lower(): k for k in obj.keys()}
            status_key = next((k for k in kl if "status" in k or "state" in k), None)
            any_job_hint = status_key or any(k in kl for k in ["jobid", "clientname", "policyname", "client", "policy"])

            if any_job_hint:
                def gv(*names):
                    for n in names:
                        if n in kl:
                            return obj.get(kl[n])
                    return None

                job = Job(
                    job_id=gv("jobid", "id", "job_id"),
                    state=gv("state"),
                    status_code=gv("status"),
                    client_name=gv("clientname", "client", "client_name"),
                    policy_name=gv("policyname", "policy", "policy_name"),
                    start_time=gv("starttime", "start_time"),
                )
                out_list.append(job)

            for v in obj.values():
                self._walk_collect_jobs(v, out_list)
        elif isinstance(obj, list):
            for it in obj:
                self._walk_collect_jobs(it, out_list)

    def get_jobs_summary(self):
        if not self.repository.table_exists():
            return {'running': 0, 'success': 0, 'warning': 0, 'failed': 0, 'total': 0}

        counts = {'running': 0, 'success': 0, 'warning': 0, 'failed': 0, 'total': 0}
        jobs = self.repository.get_all_jobs()

        for job in jobs:
            status = job.classify_status()
            if status:
                counts[status] += 1
                counts["total"] += 1

        return counts

    def get_client_statistics(self):
        stats = {}

        if not self.repository.table_exists():
            return stats

        jobs = self.repository.get_all_jobs()

        for job in jobs:
            parsed_jobs = self._parse_jobs_from_raw(job.raw_response or "")
            for parsed_job in parsed_jobs:
                client = parsed_job.client_name
                if client:
                    stats[client] = stats.get(client, 0) + 1

        return dict(sorted(stats.items(), key=lambda x: x[1], reverse=True))