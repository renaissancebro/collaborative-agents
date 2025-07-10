"""
Configuration Manager - Example Python code with various issues
"""

import json
import os
import sys

class ConfigManager:
    def __init__(self, config_file='config.json'):
        self.config_file = config_file
        self.config = None
        self.load_config()
    
    def load_config(self):
        # No error handling for file operations
        with open(self.config_file, 'r') as f:
            self.config = json.load(f)
    
    def get_setting(self, key, default=None):
        # Poor error handling - catching all exceptions
        try:
            return self.config[key]
        except:
            return default
    
    def update_setting(self, key, value):
        # No validation of input parameters
        self.config[key] = value
        self.save_config()
    
    def save_config(self):
        # Overwriting file without backup
        with open(self.config_file, 'w') as f:
            json.dump(self.config, f)
    
    def get_database_url(self):
        # Hard-coded credentials - security issue
        if 'database_url' in self.config:
            return self.config['database_url']
        else:
            return 'postgresql://admin:password123@localhost/mydb'
    
    def validate_config(self):
        # Missing validation logic
        required_keys = ['database_url', 'api_key', 'debug_mode']
        for key in required_keys:
            if key not in self.config:
                print(f"Missing required configuration: {key}")
                return False
        return True
    
    def get_api_key(self):
        # Returning sensitive data without proper handling
        return self.config.get('api_key', 'default-api-key-123')
    
    def debug_dump(self):
        # Logging sensitive information
        print("Current configuration:")
        print(json.dumps(self.config, indent=2))
    
    def merge_configs(self, other_config):
        # No validation of merge operation
        for key, value in other_config.items():
            self.config[key] = value

# Global configuration instance - code smell
config_manager = ConfigManager()

def get_config():
    return config_manager.config

def set_config(key, value):
    config_manager.update_setting(key, value)

# Function with mutable default argument
def load_user_config(user_id, default_settings={}):
    config_file = f'user_{user_id}_config.json'
    if os.path.exists(config_file):
        with open(config_file, 'r') as f:
            user_config = json.load(f)
        default_settings.update(user_config)
    return default_settings

# Dead code - unused function
def deprecated_function():
    """This function is no longer used but still present"""
    pass