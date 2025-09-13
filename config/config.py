import os
import json


class ConfigManager:
    def __init__(self, working_dir):
        self.working_dir = working_dir
        self.config_file = os.path.join(working_dir, "nb_config.json")
        self.config = self._load_config()

    def _load_config(self):
        default_config = {
            "nb_server": "https://win-t89q8gl89g1:1556",
            "username": "nbwebsvc",
            "password": "*************.master",
            "update_interval": 30,
            "api_timeout": 15,
            "retry_attempts": 3
        }

        if not os.path.exists(self.config_file):
            try:
                with open(self.config_file, "w", encoding="utf-8") as f:
                    json.dump(default_config, f, indent=4, ensure_ascii=False)
            except Exception:
                pass
            return default_config
        else:
            try:
                with open(self.config_file, "r", encoding="utf-8") as f:
                    return {**default_config, **json.load(f)}
            except Exception:
                return default_config

    def edit_config(self):
        try:
            if os.name == "nt":
                os.system(f'notepad "{self.config_file}"')
            return True
        except Exception as e:
            raise Exception(f"Config açma hatası: {e}")