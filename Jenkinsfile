pipeline {
  
  agent any
  
  stages {
    
    stage('Checkout') {
      steps {
        deleteDir()
        git 'https://github.com/Ameerbatcha/Angularapp.git'
      }
    }

    
 stage('Build') {
            steps {
                sh 'tar czf Node.tar.gz *'
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
                        execCommand: """cd /opt/docker; 
                                        tar -xf Node.tar.gz; 
                                        rm -rf Node.tar.gz;
                                       
                                        """, 
                        execTimeout: 200000,
                        flatten: false,
                        makeEmptyDirs: false,
                        noDefaultExcludes: false,
                        patternSeparator: '[, ]+$',
                        remoteDirectory: '//opt//docker//',
                        remoteDirectorySDF: false,
                        removePrefix: '',
                        sourceFiles: '**/*.gz'
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
