pipeline {
  
  agent any

   environment {
      DOCKER_TAG = getVersion()
      DOCKER_CRED = credentials('dockerhub')
  
    }
  
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
                                        docker build . -t ameerbatcha/angularapp:${DOCKER_TAG} 
                                        docker login -u ameerbatcha -p ${DOCKER_CRED}
                                        docker push ameerbatcha/angularapp:${DOCKER_TAG}
                                        """, 
                        execTimeout: 2000000,
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

      stage('Docker Deploy') {
            steps {
              script {
              
                    def ansiblePlaybookContent = '''
                    - hosts: dockeradmin
                      become: True
                    


                      tasks:
                        - name: Install python pip
                          yum:
                            name: python-pip
                            state: present

                        - name: Install docker-py python module
                          pip:
                            name: docker-py
                            state: present

                        - name: Start the container
                          docker_container:
                            name: nodecontainer
                            image: "ameerbatcha/angularapp:{{ DOCKER_TAG }}"
                            state: started
                            published_ports:
                              - 0.0.0.0:8081:80
                    '''

                    writeFile(file: 'inline_playbook.yml', text: ansiblePlaybookContent)

                   def ansibleInventoryContent = '''[dockeradmin]
                     172.31.3.63 ansible_user=ec2-user
                    '''

                    writeFile(file: 'dev.inv', text: ansibleInventoryContent)

   
                 

                  ansiblePlaybook(
                                 inventory: 'dev.inv',
                                 playbook: 'inline_playbook.yml',
                                 credentialsId: 'dev-dockerhost',
                                 extras: "-e DOCKER_TAG=${DOCKER_TAG}",
                                 installation: 'ansible',
                                 disableHostKeyChecking: true,
                               
                              
)

                
              
            }
            }
        }

    }




post {
  
  always {

      script {
node{

             

    emailext (
      subject: "Jenkins Notification: Production file deployment for ${env.JOB_NAME} - ${currentBuild.result}, Build ID: #${env.BUILD_NUMBER}",
      
      body: """
       
        Hi DevOps Team,

        Production File Deployment Process for ${env.JOB_NAME} ${env.BUILD_NUMBER} is ${currentBuild.result}. Kindly check the logs below for more details.

        Please find the last commit details below:

        See attached diff of ${env.JOB_NAME} #${env.BUILD_NUMBER}.

        Commit Id: ${env.GIT_COMMIT}

        Source Path: ${env.WORKSPACE}

        Author: ${env.GIT_AUTHOR_EMAIL}

        Commit Dates: ${env.GIT_COMMIT_TIMESTAMP}

        Production Deployment - ${currentBuild.result}

        Changes in Commit:\n
        ${sh(script: "git diff HEAD^ HEAD", returnStdout: true)}

        With Regards,

        Jenkins Admin
        """,
      
      to: "ameerbatcha.learnings@gmail.com",
     
      mimeType: 'text/plain'
    )
    }
   }
 }
}



      
  
}


def getVersion(){
    def commitHash = sh label: '', returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitHash
}



    
   

    
