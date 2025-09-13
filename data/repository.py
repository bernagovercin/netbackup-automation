import sqlite3
import os
from models.job import Job


class JobRepository:
    def __init__(self, db_path):
        self.db_path = db_path

    def get_connection(self):
        return sqlite3.connect(self.db_path)

    def get_all_jobs(self):
        jobs = []
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT job_id, request_time, raw_response FROM job_logs")

            for row in cursor.fetchall():
                job = Job(
                    job_id=row[0],
                    request_time=row[1],
                    raw_response=row[2]
                )
                jobs.append(job)

            conn.close()
        except Exception as e:
            raise Exception(f"Job'lar getirilemedi: {e}")

        return jobs

    def get_job_count(self):
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM job_logs")
            count = cursor.fetchone()[0]
            conn.close()
            return count
        except Exception as e:
            raise Exception(f"Job sayısı getirilemedi: {e}")

    def table_exists(self):
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='job_logs'")
            exists = cursor.fetchone() is not None
            conn.close()
            return exists
        except Exception:
            return False