pipeline {
  
  agent any
  
  stages {
    
    stage('Checkout') {
      steps {
        git 'https://github.com/Ameerbatcha/Angularapp.git'
      }
    }
    
    stage('Build') {
      steps {
        sh 'docker build . -t angular-app:latest '
      }
    }
    
    stage('Publish') {
      steps {
        sh 'docker run -d -p 80:80 angular-app:latest'
      }
    }
    
  }
  
}
