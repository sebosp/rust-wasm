pipeline {
    agent {
        label "jenkins-rust"
    }
    environment {
      ORG               = 'sebosp'
      APP_NAME          = 'rust-wasm'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
      RUST_VERSION      = '1.27.1'
    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'feature/*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          container("registry.hub.docker.com/sebosp/rust-wasm-base:${RUST_VERSION}") {
            sh 'cd wasm-data'
            sh 'cargo +nightly build --target wasm32-unknown-unknown --release'
            sh 'wasm-gc target/wasm32-unknown-unknown/release/wasm_data.wasm -o target/wasm32-unknown-unknown/release/wasm_data.gc.wasm'
            stash includes: '*/target/wasm32-unknown-unknown/release/wasm_data_gc.wasm', name: 'wasm-gc'
          }
          container("rust:${RUST_VERSION}") {
	    dir('./static') {
              unstash 'wasm-gc'
	    }
            sh 'rustup override set nightly'
            sh 'cargo install'
            sh "cp ~/.cargo/bin/rust-wasm ."

            sh 'export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml'

            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }

          dir ('./charts/preview') {
           container('rust') {
             sh "make preview"
             sh "jx preview --app $APP_NAME --dir ../.."
           }
          }
        }
      }
      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          container('rust') {
            // ensure we're not on a detached head
            sh "git checkout master"
            sh "git config --global credential.helper store"

            sh "jx step git credentials"
            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
          }
          dir ('./charts/rust-wasm') {
            container('rust') {
              sh "make tag"
            }
          }
          container('rust') {
            // seems we need to upgrade rust else we get compile errors using Rust 1.24.1
            sh 'rustup override set nightly'
            sh "cargo install"
            sh "cp ~/.cargo/bin/rust-wasm ."

            sh 'export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml'

            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
          }
        }
      }
      stage('Promote to Environments') {
        when {
          branch 'master'
        }
        steps {
          dir ('./charts/rust-wasm') {
            container('rust') {
              sh 'jx step changelog --version \$(cat ../../VERSION)'

              // release the helm chart
              sh 'jx step helm release'

              // promote through all 'Auto' promotion Environments
              sh 'jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)'
            }
          }
        }
      }
    }
    post {
        always {
            cleanWs()
        }
    }
  }
