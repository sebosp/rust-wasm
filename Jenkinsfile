pipeline {
  agent {
      label "jenkins-rust"
  }
  environment {
    ORG               = 'sebosp'
    APP_NAME          = 'rust-wasm'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    RUST_VERSION      = '1.27.2'
  }
  stages {
    stage('CI Build and push snapshot') {
      when {
        anyOf {
          branch 'feature-*';
          branch 'PR-*'
        }
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container("rust") {
/*          sh 'rustup override set nightly'
          sh 'rustup default nightly'
          sh 'rustup target add wasm32-unknown-unknown --toolchain nightly'
          sh 'cargo install wasm-gc --root ./tmp'
          sh 'git clone --depth 1 https://github.com/juj/emsdk.git'
          sh 'emsdk/emsdk install latest'
          sh 'emsdk/emsdk activate latest'
          sh 'cargo +nightly build --target wasm32-unknown-unknown --release -p wasm-data'
          sh './tmp/bin/wasm-gc target/wasm32-unknown-unknown/release/wasm_data.wasm -o static/wasm_data.gc.wasm'
          sh "cp ./target/release/rust-wasm ."*/
          sh './build.sh'
          sh 'cargo install --path .'
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
        dir ('./static') {
          unstash 'wasm_data'
        }
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
