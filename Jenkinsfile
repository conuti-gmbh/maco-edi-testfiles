pipeline {
    agent any
    environment {
        BASE_NAMESPACE="edi-testfiles-${env.BUILD_NUMBER}"
        DOCKER_HOST=credentials('docker-host')
    }
    options {
        parallelsAlwaysFailFast()
        disableConcurrentBuilds(abortPrevious: true)
    }
    stages {
        stage('Prepare docker image'){
        steps {
               script {
                   HASH= sh (
                       script: """echo $BRANCH_NAME| md5sum | cut -d " " -f1""",
                       returnStdout: true
                   ).trim()
               }
                withCredentials([file(credentialsId: 'docker-config', variable: 'DOCKER_JSON'),file(credentialsId: 'git-id-rsa', variable: 'GIT_ID_RSA')]) {
                 sh """#!/bin/bash -xe
                 set +x
                 mkdir -p ~/.docker
                 cp $DOCKER_JSON  ~/.docker/config.json
                 cd docker/webserver && docker build --build-arg SSH_PRV_KEY="\$(cat $GIT_ID_RSA)" -t registry.conuti.de/cu-powercloud/lib/cdoc-specification:$HASH .
                 docker push  registry.conuti.de/cu-powercloud/lib/edi-testfiles:$HASH
                 """
               }

          }
        }

        stage('Create test env 1') {
            steps {
               sh """
               kubectl create ns  $BASE_NAMESPACE-$HASH || true
               sed -i 's|__NAMESPACE__|$BASE_NAMESPACE-$HASH|g' k8s/manifests/test/*.yaml
               sed -i 's|edi-testfiles:test|edi-testfiles:$HASH|g' k8s/manifests/test/app.yaml
               kubectl apply -f 'k8s/manifests/test/*'
               kubectl rollout status deployment/app -n $BASE_NAMESPACE-$HASH
               pod_name=\$(kubectl get pod -n $BASE_NAMESPACE-$HASH | grep app | awk '{print \$1}')
               kubectl cp . \$pod_name:/var/www/html -n $BASE_NAMESPACE-$HASH
	       kubectl exec \$pod_name -n $BASE_NAMESPACE-$HASH -- composer install
			   """
            }
        }
        stage ('Code analysis') {
        parallel {
            stage('PHP CS Check') {
            steps {

               sh """
               pod_name=\$(kubectl get pod -n $BASE_NAMESPACE-$HASH | grep app | awk '{print \$1}')
               kubectl exec \$pod_name -n $BASE_NAMESPACE-$HASH --  vendor/bin/phpcs

                """
            }}
            stage('PHP Stan Check') {
            steps {

               sh """
                pod_name=\$(kubectl get pod -n $BASE_NAMESPACE-$HASH | grep app | awk '{print \$1}')
                kubectl exec \$pod_name -n $BASE_NAMESPACE-$HASH -- vendor/bin/phpstan analyse -c phpstan.neon --memory-limit 256M
                """
            }}

            }
           }



}

   post {
            cleanup {
               sh """
               kubectl delete ns  $BASE_NAMESPACE-$HASH|| true
               """

               cleanWs()
            }
        }
}
