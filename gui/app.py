import tkinter as tk
from tkinter import messagebox, scrolledtext
import subprocess
import os
import threading
import time
from datetime import datetime
from config import ConfigManager
from services.job_service import JobService

class NetBackupGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("NetBackup API Otomasyon Sistemi")
        self.root.geometry("1200x800")
        self.root.configure(bg="#2c3e50")

        # Çalışma dizini
        self.working_dir = r"C:\Users\Administrator\Desktop\app"

        # Servisler
        self.config_manager = ConfigManager(self.working_dir)
        self.job_service = JobService(os.path.join(self.working_dir, "netbackup.db"))

        # Asset yolları
        self.ico_path = self._resolve_path(os.path.join(self.working_dir, "choestity_ico"), [".ico", ".ICO"])
        self.logo_path = self._resolve_path(os.path.join(self.working_dir, "choestity_logo"), [".png", ".PNG", ".gif", ".GIF"])

        # Pencere ikonu
        try:
            if self.ico_path:
                self.root.iconbitmap(self.ico_path)
        except Exception:
            pass

        # UI
        self.setup_ui()

        # Arkaplan güncelleme
        self.start_dashboard_updates()
