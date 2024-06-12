# Readme.md

## フォークした概要
Googleのログインフォームの変更により、BeatifulSoupのログイン周りの挙動がうまくいかない様になっていたので、そのあたりを、playwrightを使用してブラウザログインで対応できるようにした。

## ビルド
playwrightをインストールしたイメージを作成する
```bash
$ docker build --target playwright -t aws-google-auth .
```
## docker image push
以下のURLを参考にリポジトリへイメージをPUSHします
- [Docker イメージを Amazon ECR プライベートリポジトリにプッシュする](https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/docker-push-ecr-image.html)

## image repository
イメージのリポジトリはECR(private)で以下になります
`350296027863.dkr.ecr.ap-northeast-1.amazonaws.com/comsbi-common/aws-google-auth`

## 実行
実行方法は、aws-google-authコマンドに`--saml-assertion`オプションでsaml_responseを渡せるようにsamlレスポンスだけ取得するコマンドを追加
```bash
$ docker run -it --rm --entrypoint login-playwright aws-google-auth
# オプション類書略あり
```
上記のコマンドの出力にSAML Responseが出力されるので、通常のaws-google-authコマンドのオプションにSAMLを渡して実行する。

## おまけ
ローカルに以下のようなスクリプトを置いておくと実行時ちょっとだけ楽になります。
```bash
# /dir/to/path/aws-google-auth(パスが通っているところへおく)
#!/bin/bash

GOOGLE_USERNAME=xxxxxxx@sonicmoov.com
GOOGLE_PASSWORD=xxxxxxx
GOOGLE_IDP_ID=XXXXXXXX
GOOGLE_SP_ID=000000000000
AWS_REGION=ap-northeast-1
ROLE_ARN=arn:aws:iam::xxxxxxxx:role/smv_console_admin
DURATION=43200
IMAGE="350296027863.dkr.ecr.ap-northeast-1.amazonaws.com/comsbi-common/aws-google-auth:playwright-0.0.1"

# saml_assertion
saml=$(docker run -it --rm \
    -e GOOGLE_USERNAME=${GOOGLE_USERNAME} \
    -e GOOGLE_PASSWORD=${GOOGLE_PASSWORD} \
    -e GOOGLE_IDP_ID=${GOOGLE_IDP_ID} \
    -e GOOGLE_SP_ID=${GOOGLE_SP_ID} \
    -e AWS_REGION=${AWS_REGION} \
    -e ROLE_ARN=${ROLE_ARN} \
    -e DURATION=${DURATION} \
    -v ~/.aws:/root/.aws \
    --entrypoint login-playwright \
    ${IMAGE})
#echo "${saml}"

docker run -it --rm \
    -e GOOGLE_USERNAME=${GOOGLE_USERNAME} \
    -e GOOGLE_PASSWORD=${GOOGLE_PASSWORD} \
    -e GOOGLE_IDP_ID=${GOOGLE_IDP_ID} \
    -e GOOGLE_SP_ID=${GOOGLE_SP_ID} \
    -e AWS_REGION=${AWS_REGION} \
    -e ROLE_ARN=${ROLE_ARN} \
    -e DURATION=${DURATION} \
    -v ~/.aws:/root/.aws \
    ${IMAGE} --saml-assertion ${saml} "$@"
```
