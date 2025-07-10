// Data Processor - Example Node.js code with intentional issues

const fs = require('fs');
const path = require('path');

class DataProcessor {
    constructor() {
        this.data = [];
        this.cache = {};
        this.isProcessing = false;
    }
    
    // Inefficient data loading - synchronous file operations
    loadData(filename) {
        try {
            const content = fs.readFileSync(filename, 'utf8');
            this.data = JSON.parse(content);
            return true;
        } catch (error) {
            console.log('Error loading data'); // Poor error handling
            return false;
        }
    }
    
    // Performance issue - O(n²) complexity
    findDuplicates(arr) {
        const duplicates = [];
        for (let i = 0; i < arr.length; i++) {
            for (let j = i + 1; j < arr.length; j++) {
                if (arr[i] === arr[j]) {
                    duplicates.push(arr[i]);
                }
            }
        }
        return duplicates;
    }
    
    // Code smell - long parameter list
    processUserData(id, name, email, phone, address, city, state, zip, country, age, gender, occupation) {
        // Missing input validation
        const user = {
            id: id,
            name: name,
            email: email,
            phone: phone,
            address: address,
            city: city,
            state: state,
            zip: zip,
            country: country,
            age: age,
            gender: gender,
            occupation: occupation
        };
        
        // Inefficient string concatenation
        let result = '';
        result += 'User: ' + user.name + '\n';
        result += 'Email: ' + user.email + '\n';
        result += 'Phone: ' + user.phone + '\n';
        result += 'Address: ' + user.address + '\n';
        
        return result;
    }
    
    // Security issue - eval usage
    calculateExpression(expression) {
        try {
            return eval(expression);
        } catch (error) {
            return null;
        }
    }
    
    // Memory leak - growing array without cleanup
    logActivity(message) {
        if (!this.activityLog) {
            this.activityLog = [];
        }
        this.activityLog.push({
            timestamp: Date.now(),
            message: message
        });
    }
    
    // Inefficient lookup - should use Map
    getUserById(userId) {
        for (let i = 0; i < this.data.length; i++) {
            if (this.data[i].id === userId) {
                return this.data[i];
            }
        }
        return null;
    }
    
    // Code smell - deeply nested callbacks
    processDataAsync(callback) {
        this.loadData('data.json', (err, data) => {
            if (err) {
                callback(err);
            } else {
                this.validateData(data, (err, validData) => {
                    if (err) {
                        callback(err);
                    } else {
                        this.transformData(validData, (err, transformedData) => {
                            if (err) {
                                callback(err);
                            } else {
                                this.saveData(transformedData, (err, result) => {
                                    if (err) {
                                        callback(err);
                                    } else {
                                        callback(null, result);
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    }
    
    // Magic numbers - code smell
    calculateScore(data) {
        let score = 0;
        if (data.length > 100) {
            score += 50;
        }
        if (data.accuracy > 0.85) {
            score += 30;
        }
        if (data.completeness > 0.9) {
            score += 20;
        }
        return score;
    }
    
    // No error handling
    writeToFile(filename, data) {
        fs.writeFileSync(filename, JSON.stringify(data));
    }
}

// Global variables - code smell
var globalProcessor = new DataProcessor();
var isInitialized = false;

// Function with side effects
function initializeGlobal() {
    globalProcessor.loadData('config.json');
    isInitialized = true;
    console.log('Global processor initialized');
}

// Unused variable
const unusedVariable = 'This variable is never used';

module.exports = DataProcessor;