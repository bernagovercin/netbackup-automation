class Job:
    def __init__(self, job_id=None, state=None, status_code=None,
                 client_name=None, policy_name=None, start_time=None):
        self.job_id = job_id
        self.state = state
        self.status_code = status_code
        self.client_name = client_name
        self.policy_name = policy_name
        self.start_time = start_time

    def classify_status(self):
        s = (self.state or "").strip().lower()
        code = None

        if self.status_code is not None and self.status_code != "":
            try:
                code = int(str(self.status_code).strip())
            except Exception:
                code = None

        if any(x in s for x in ["running", "active", "in_progress", "inprogress"]):
            return "running"

        if code is not None:
            if code == 0:
                return "success"
            if code == 1:
                return "warning"
            return "failed"

        if s in ["done", "completed", "complete", "success", "ok", "finished"]:
            return "success"
        if "warn" in s or s in ["partial", "partially_successful"]:
            return "warning"
        if any(x in s for x in ["fail", "error", "failed"]):
            return "failed"

        return None