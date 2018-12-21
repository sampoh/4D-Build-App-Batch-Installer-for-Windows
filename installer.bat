@if (@This==@IsBatch) @then
@echo off
echo インストール中です。このウインドウは閉じないでください。
    setlocal enableextensions disabledelayedexpansion
    wscript //E:JScript "%~dpnx0"
    exit /b
@end
// --- ここからJavaScript ---

//↓↓ここからアプリに応じた各種設定 ( 要修正 ) ↓↓
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
//↑↑ここまでアプリに応じた各種設定 ( 要修正 )↑↑

//各基本機能を使用するための宣言
var fs = new ActiveXObject("Scripting.FileSystemObject");
var http = WScript.CreateObject("Msxml2.XMLHTTP.6.0");
var strm = WScript.CreateObject("Adodb.Stream");
var sh = new ActiveXObject("WScript.Shell");
var shell = new ActiveXObject("Shell.Application");

//WSH定数を変数として定義
var adTypeBinary = 1,adSaveCreateOverWrite = 2;
var BTN_OK_CANCL = 1,ICON_EXCLA = 48;

var rtn = sh.Popup("\""+settings.appName+"\" をインストールします。\r\nよろしいですか？",0,"インストール",(BTN_OK_CANCL + ICON_EXCLA));
if(rtn != 1){
	WScript.Echo("インストールをキャンセルしました。");
	WScript.Quit(0);
}

var userPath = sh.ExpandEnvironmentStrings("%UserProfile%");
var installDir = userPath + "\\";
if(settings.parentDir != ''){ installDir += settings.parentDir+"\\"; }
var desktop = sh.SpecialFolders("Desktop");
var scpath = {
	link:desktop + "\\" + settings.shortcut.name,
	real:installDir + settings.shortcut.path
};

var tmpdir = fs.GetSpecialFolder(2);
var savefile = tmpdir + "\\" + generateUuid() + ".zip";
//WScript.Echo(savefile);

http.open("GET",settings.url,false);
http.send();

if(http.status == 200){
	strm.Type = adTypeBinary;
	strm.Open();
	strm.Write(http.responseBody); // 書き込み
	strm.Savetofile(savefile,adSaveCreateOverWrite); // 保存
}else{
	WScript.Echo("通信エラーのため中断します。");
	WScript.Quit(0);
}

unzip(savefile,installDir);
fs.DeleteFile(savefile);

generateShortCut(scpath.link,scpath.real)

var thisPath = fs.getParentFolderName(WScript.ScriptFullName+"\\"+WScript.ScriptName);
//WScript.Echo(thisPath);


var FLG_REMOVE = false;
if(settings.confirm){
	var rtn = sh.Popup("インストールが完了しました。\r\nこのインストールスクリプトを削除します。\r\nよろしいですか？",0,"確認",(BTN_OK_CANCL + ICON_EXCLA));
	FLG_REMOVE = (rtn == 1);
}else{
	FLG_REMOVE = true;
}
if(FLG_REMOVE){ fs.DeleteFile(thisPath); }

sh = null;
fs = null;

WScript.Echo("インストールが完了しました。");

WScript.Quit(0);

function generateUuid(){
	var chars = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx".split("");
	for(var i = 0, len = chars.length; i < len; i++) {
		switch (chars[i]) {
			case "x":
				chars[i] = Math.floor(Math.random() * 16).toString(16);
				break;
			case "y":
				chars[i] = (Math.floor(Math.random() * 4) + 8).toString(16);
			break;
		}
	}
	return chars.join("");
}

function createFolder(folderpath){
	if(!fs.FolderExists(folderpath)){
		if(fs.GetParentFolderName(folderpath)){
			createFolder(fs.GetParentFolderName(folderpath));
			fs.CreateFolder(folderpath);
		}
	}
}

function unzip(zipfile,folder){
	if(fs.FileExists(zipfile) && fs.GetExtensionName(zipfile).toLowerCase() == "zip"){
		var unzip = null;
		if(folder){
			if(!fs.FolderExists(folder)){ createFolder(folder); }
			unzip = folder;
		}
		if(unzip != null){ shell.NameSpace(folder).CopyHere(shell.NameSpace(zipfile).Items(),20); }
    }
}

function generateShortCut(link,real){

	var WINSTL_NOMAL    = 1;    // ウインドウをアクティブにし、通常サイズで表示
	var WINSTL_MAX      = 3;    // ウインドウをアクティブにし、最大化サイズで表示
	var WINSTL_MIN      = 7;    // 最小化で表示し、次に上位となるウインドウをアクティブにする

	//ショートカットファイル生成
	var file = sh.CreateShortcut(link);

	//ショートカットの参照先パスを設定
	//( 先頭に「file:/」を付加するとアイコンが自動設定される )
	file.TargetPath = "file:/" + real.replace(/\\/g,"/");

	//ショートカットファイルの実行時のアプリケーションの
	//ウインドウスタイルを設定
	file.WindowStyle = WINSTL_NOMAL;

	//アイコンを設定
	//file.IconLocation = "";

	//ショートカットファイルに割り当てるショートカットキーを設定
	//file.Hotkey = "CTRL+SHIFT+A";

	//ショートカットキーが使用できる階層を本ファイルと
	//同階層に設定
	//file.WorkingDirectory = ".";

	//ショートカットファイルを保存
	file.Save();

}
