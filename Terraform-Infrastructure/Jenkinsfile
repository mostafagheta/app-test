pipeline {
    agent {
        label 'ec2-static'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }
    
    stages {
        
        stage('Check Versioning') {
            steps {
                script {
                    def hasChanges = checkS3Version()
                    if (!hasChanges) {
                        currentBuild.result = 'SUCCESS'
                        echo "No version changes detected. Skipping pipeline."
                        env.SKIP_PIPELINE = 'true'
                    } else {
                        echo "Version change detected. Updating S3 version bucket immediately."
                        updateS3Version()
                    }
                }
            }
        }
         stage('Terraform Init') {
            steps {
                terraformInit()
            }
        }

        stage('Terraform Validate') {
            steps {
                terraformValidate()
            }
        }

        stage('Terraform Lint') {
            steps {
                terraformLint()
            }
        }

        stage('Terraform Security Scan') {
            steps {
                terraformSecurity()
            }
        }

        stage('Terraform Plan') {
            steps {
                terraformPlan()
            }
        }

        stage('Policy / Compliance Check') {
            steps {
                terraformPolicy()
            }
        }

        stage('Approval') {
            steps {
                terraformApproval()
            }
        }

        stage('Terraform Execute') {
            steps {
                terraformApply()
            }
        }
        stage('Archive Artifacts') {
         steps {
            archiveInventory()
         }
            }
    }
}