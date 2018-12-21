# 4D-Build-App-Batch-Installer-for-Windows
4Dビルドアプリをインターネット上からダウンロードし、ユーザフォルダ以下にインストールしデスクトップにショートカットを作成するためのバッチファイルによるインストーラです。

ソース上の以下、
```javascript
var settings = {
	appName:"ABC_Client", //インストール時にこのスクリプトが出力するコンファームに表示するアプリ名
	url:"https://<ドメインおよびIPアドレスなど>/ABC_Client.zip", //ZIP圧縮した4DビルドアプリのダウンロードURL
	parentDir:"Sampoh Apps", //ユーザフォルダに作成する親フォルダ ( ※ブランクの場合は直展開する仕様 )
	shortcut:{ //ショートカット設定
		name:"ABC_Client.lnk",//ショートカットファイル名
		path:"ABC_Client\\ABC_Client.exe"//ZIPファイル展開後のexeファイルまでの相対パス
	},
	confirm:false //このスクリプト自身を削除する際にコンファームを出すかどうかの指定 ( ※ falseの場合は自動削除 )
};
```
の部分を対象アプリに合わせて修正することで動作します。
