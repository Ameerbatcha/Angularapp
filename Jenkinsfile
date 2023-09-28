
pipeline {
  
  agent any

   environment {
      DOCKER_TAG = getVersion()
      DOCKER_CRED = credentials('dockerhub')
      LATEST_COMMITTER_EMAIL = latestCommitterEmail()
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

      stage('Deploy UAT-Server') {

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
                            name: angularcontainer
                            image: "ameerbatcha/angularapp:{{DOCKER_TAG}}"
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

        post {
  
  success {

      script {



   def currentCommit = sh(returnStdout: true, script: 'git rev-parse HEAD')
   def currentCommitcodeChange = sh(script: "git diff HEAD~1 ${currentCommit}", returnStdout: true)
   def currentcommitdetails =  sh(script: 'git show --name-status ${currentCommit}', returnStdout: true).trim()
//   def currentcommitdetails =  sh(script: 'git show --name-status HEAD^', returnStdout: true).trim()
   
    def previousCommitDetails = sh(script: 'git show --name-status HEAD^', returnStdout: true).trim()
    def previousCommitCodeChange = sh(script: "git diff HEAD~2 HEAD~1", returnStdout: true)
    
   
   
   def previousCommit = sh(returnStdout: true,script: 'git log -2 --format="%H,%cd,%ae" --date=format:"%Y-%m-%d %H:%M:%S" | sed -n 2p').trim()
   def previousCommitArray = previousCommit.split(",")
   def previousCommitId = previousCommitArray[0].trim()
   def previousCommitDate = previousCommitArray[1].trim()
   def previousCommitAuthor = previousCommitArray[2].trim()
   
   
   def finallog = currentcommitdetails + "\n\n" + currentCommitcodeChange + "\n\n" + previousCommitDetails + "\n\n" + previousCommitCodeChange
   def latestCommitDate = sh(script: 'git log -1 --format=%cd --date=format:"%Y-%m-%d %H:%M:%S"', returnStdout: true).trim()

    writeFile file: "latest_code_changes.txt", text: finallog
    
    
    emailext (
      subject: "Jenkins Notification: UAT  deployment for ${env.JOB_NAME} - ${currentBuild.result}, Build ID: #${env.BUILD_NUMBER}",
      
      body: """
       
        Hi DevOps Team, <br><br><br>

        File Deployment in UAT server for <b> ${env.JOB_NAME} ${env.BUILD_NUMBER} is ${currentBuild.result}. </b> Kindly check the logs below for more details.<br><br>

        Please find the last commit details below:<br><br>

        Project/Pipeline: <b> ${env.JOB_NAME} #${env.BUILD_NUMBER}. </b> <br><br>
        
        Docker tag/Git commit ID short:<b> ${env.DOCKER_TAG} </b> <br><br>

        Latest Git Commit Id full: <b>${currentCommit}</b><br><br>   
        
        Latest Committer Email: <b> ${LATEST_COMMITTER_EMAIL} </b><br><br>
        
        Latest Commited Date - <b>${latestCommitDate} </b> <br><br>
 
        
        Previous Git Commit Id full: <b>${previousCommitId}</b> <br>  Previous Committer Email: <b>${previousCommitAuthor}</b> <br>  Previous Commited Date - <b>${previousCommitDate} </b><br><br>

        Source Path: <b> ${env.WORKSPACE} </b><br><br>

        UAT-server Deployment - <b>${currentBuild.result} </b> <br><br>
        
       
        <b>Please Approve for Deployment in Production Server </b><br><br>

        With Regards, <br><br><br>

        Jenkins Admin
        """,
      
      to: "ameerbatcha.learnings@gmail.com",
      mimeType: 'text/html',
      attachmentsPattern: "latest_code_changes.txt"
     
  
    )
      

    }
   }  
   
     failure {

      script {


   def currentCommit = sh(returnStdout: true, script: 'git rev-parse HEAD')
   def gitDiffOutput = sh(script: "git diff HEAD~1 ${currentCommit}", returnStdout: true)
   def changes =  sh(script: 'git show --name-status HEAD^', returnStdout: true).trim()
   def latestCommitDate = sh(script: 'git log -1 --format=%cd --date=format:"%Y-%m-%d %H:%M:%S"', returnStdout: true).trim()
 
def buildLog = currentBuild.rawBuild.getLog(1000).join('\n')


def errors = buildLog.readLines().findAll { line ->
    line.contains("Error:")
}.join('\n')

// def errors = sh(script: 'grep -r "Error:" .', returnStdout: true).trim()

                
  def finallog = changes + "\n\n" + errors + "\n\n" + gitDiffOutput
 
    writeFile file: "error_made.txt", text: finallog
    
    
    emailext (
      subject: "Jenkins  ${currentBuild.result} Notification: UAT  deployment for ${env.JOB_NAME} - ${currentBuild.result}, Build ID: #${env.BUILD_NUMBER}",
      
      body: """
       
        Hi Developers, <br><br><br>

        File Deployment in UAT server for <b> ${env.JOB_NAME} ${env.BUILD_NUMBER} is ${currentBuild.result}. </b> Kindly check the logs below for more details.<br><br>

        Please find the logs below:<br><br>

        Project/Pipeline: <b> ${env.JOB_NAME} #${env.BUILD_NUMBER}. </b> <br><br>
        
        Git Commit Id full: <b>${currentCommit}</b><br><br>   
        
        Latest Committer Email: <b> ${LATEST_COMMITTER_EMAIL} </b><br><br>

        UAT-server Deployment : <b>${currentBuild.result} </b> <br><br>
        
        Latest Commited Date : <b>${latestCommitDate} </b> <br><br>
 
        <b>Please Lookup to the Error generated attached</b><br><br>

        With Regards, <br><br><br>

        Jenkins Admin
        """,
      
      to: "ameerbatcha.photos1@gmail.com",
      mimeType: 'text/html',
      attachmentsPattern: "error_made.txt"
     
  
    )
      

    }
   }
   
   
   
   
   
 
 }
 
 
}



stage('Deploy production-Server') {
              steps {
                   script {
                  

            def approval = input(
            id: 'production-approval',
            message: 'Do you want to deploy the production server?',
            parameters: [
              choice(
                name: 'deploy',
                choices: ['Yes', 'No'],
                defaultValue: 'No',
                description: 'Deploy production server?'
              )
            ]
          )      
        
           if (approval == 'Yes') {
          
         
                    
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
                            name: angularcontainer2
                            image: "ameerbatcha/angularapp:{{DOCKER_TAG}}"
                            state: started
                            published_ports:
                              - 0.0.0.0:8082:80
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
           } else {
            error('Production deployment was not approved.')
          }   
            
       }
      }
      
        post {
  
  always {

      script {



   def currentCommit = sh(returnStdout: true, script: 'git rev-parse HEAD')
   def gitDiffOutput = sh(script: "git diff HEAD~1 ${currentCommit}", returnStdout: true)
   def changes =  sh(script: 'git show --name-status HEAD^', returnStdout: true).trim()
   
   def finallog = changes + "\n\n" + gitDiffOutput
   
    writeFile file: "latest_code_changes.txt", text: finallog
    
    
    emailext (
      subject: "Jenkins Notification: Production deployment for ${env.JOB_NAME} - ${currentBuild.result}, Build ID: #${env.BUILD_NUMBER}",
      
      body: """
       
        Hi DevOps Team, <br><br><br>

        File Deployment in Production server for <b> ${env.JOB_NAME} ${env.BUILD_NUMBER} is ${currentBuild.result}. </b> Kindly check the logs below for more details.<br><br>

        Please find the last commit details below:<br><br>

        See attached diff of <b> ${env.JOB_NAME} #${env.BUILD_NUMBER}. </b> <br><br>
        
        Docker tag/Git commit ID short:<b> ${env.DOCKER_TAG} </b> <br><br>

        Git Commit Id full: <b>${currentCommit}</b><br><br>   
        
        Latest Committer Email: <b> ${LATEST_COMMITTER_EMAIL} </b><br><br>

        Source Path: <b> ${env.WORKSPACE} </b><br><br>

        Production Deployment - <b>${currentBuild.result} </b> <br><br>
 
       

        With Regards, <br><br><br>

        Jenkins Admin
        """,
      
      to: "ameerbatcha.learnings@gmail.com",
      mimeType: 'text/html',
      attachmentsPattern: "latest_code_changes.txt"
     
  
    )
      

        }
       }  
      }
 }



    



    } 
}


def getVersion(){
    def commitHash = sh label: '', returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitHash
}


  def latestCommitterEmail(){
    def author = sh label:'', returnStdout: true , script: "git log -1 --pretty=format:%ae"
    return author
  } 
