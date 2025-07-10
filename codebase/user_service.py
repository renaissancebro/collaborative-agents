#!/usr/bin/env python3
"""
User Service Module - Example codebase with intentional issues
"""

import os
import json
import time
import hashlib

class UserService:
    def __init__(self):
        self.users = {}
        self.admin_password = "admin123"  # Hard-coded password - security issue
        
    def create_user(self, username, password, email):
        # Missing input validation
        if username in self.users:
            return False
        
        # Inefficient nested loops - performance issue
        for user_id in range(1, 1000):
            found = False
            for existing_user in self.users.values():
                if existing_user['id'] == user_id:
                    found = True
                    break
            if not found:
                break
        
        # Poor error handling
        try:
            user_data = {
                'id': user_id,
                'username': username,
                'password': password,  # Plain text password - security issue
                'email': email,
                'created_at': time.time()
            }
            self.users[username] = user_data
            return True
        except:
            return False
    
    def authenticate_user(self, username, password):
        # Code smell - deeply nested conditions
        if username in self.users:
            if self.users[username]['password'] == password:
                if self.users[username].get('active', True):
                    if not self.users[username].get('locked', False):
                        return True
                    else:
                        return False
                else:
                    return False
            else:
                return False
        else:
            return False
    
    def get_user_by_id(self, user_id):
        # Inefficient search - O(n) complexity
        for user in self.users.values():
            if user['id'] == user_id:
                return user
        return None
    
    def delete_user(self, username):
        # Missing error handling
        del self.users[username]
        return True
    
    def export_users(self, filename):
        # No input validation, potential security issue
        with open(filename, 'w') as f:
            json.dump(self.users, f)
    
    def import_users(self, filename):
        # eval() usage - major security vulnerability
        with open(filename, 'r') as f:
            content = f.read()
            self.users = eval(content)
    
    def hash_password(self, password):
        # Weak hashing algorithm
        return hashlib.md5(password.encode()).hexdigest()
    
    def log_activity(self, message):
        # No log rotation, potential disk space issue
        with open('/tmp/user_service.log', 'a') as f:
            f.write(f"{time.time()}: {message}\n")

# Global variables - code smell
current_user = None
session_timeout = 3600

def login(username, password):
    global current_user
    service = UserService()
    if service.authenticate_user(username, password):
        current_user = username
        return True
    return False

def logout():
    global current_user
    current_user = None