pipeline {
  
  agent any
  
  stages {
    
    stage('Checkout') {
      steps {
        deleteDir()
        git 'https://github.com/Ameerbatcha/Angularapp.git'
      }
    }

    
      stage('Docker Build'){
    steps{
      
        sshPublisher(publishers: [
            sshPublisherDesc(
                configName: 'docker',
                transfers: [
                    sshTransfer(
                        cleanRemote: false,
                        excludes: '',
                       /* execCommand: """cd /opt/docker; 
                                        tar -xf Node.tar.gz; 
                                        docker build . -t angular-app:latest
                                        docker run -d --name angularapp -p 80:80 angular-app:latest
                                        """, */
                        execTimeout: 200000,
                        flatten: false,
                        makeEmptyDirs: false,
                        noDefaultExcludes: false,
                        patternSeparator: '[, ]+$',
                        remoteDirectory: '//opt//docker//',
                        remoteDirectorySDF: false,
                        removePrefix: '/var/lib/jenkins/workspace/',
                        sourceFiles: '/var/lib/jenkins/workspace/angular-pipeline/*'
                    )
                ],
                usePromotionTimestamp: false,
                useWorkspaceInPromotion: false,
                verbose: true
            )
        ])
    }
}

    
   

    
  }
  
}
