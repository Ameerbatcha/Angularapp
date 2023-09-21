pipeline {
  
  agent any

   environment {
      DOCKER_TAG = getVersion()
      DOCKER_CRED = credentials('dockerhub')
  
    }
  
  stages {
    
   



post {
  
  always {

      script {
node{

      try {

    emailext (
      subject: "Jenkins Notification: Production file deployment for ${env.JOB_NAME} - ${currentBuild.result}, Build ID: #${env.BUILD_NUMBER}",
      
      body: """
       
        Hi DevOps Team, <br><br><br>

        Production File Deployment Process for  <b> ${env.JOB_NAME} ${env.BUILD_NUMBER} is ${currentBuild.result}. </b> Kindly check the logs below for more details.<br><br>

        Please find the last commit details below:<br><br>

        See attached diff of <b> ${env.JOB_NAME} #${env.BUILD_NUMBER}. </b> <br><br>
        
        Docker tag/Git commit ID short:<b> ${env.DOCKER_TAG} </b> <br><br>

        Git Commit Id full: <b> ${env.GIT_COMMIT} </b><br><br>

        Source Path: <b> ${env.WORKSPACE} </b><br><br>

        Production Deployment - <b>${currentBuild.result} </b> <br><br>


        With Regards, <br><br><br>

        Jenkins Admin
        """,
      
      to: "ameerbatcha.learnings@gmail.com",
     
      mimeType: 'text/html'
    )
      }
  catch (Exception e) {
                    emailext (
                        subject: "Jenkins Notification: Pipeline Failure",
                        body: "The pipeline failed to execute due to a syntax error.",
                        to: "ameerbatcha.learnings@gmail.com"
                    )
                    throw e
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



    
   

    
