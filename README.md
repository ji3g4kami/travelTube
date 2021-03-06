 # travelTube
Watch Youtube and travel!</br>
有時候看 youtuber 們吃美食或出去玩，youtube 並沒有相關的地理資訊。或者我們過了一兩天就忘記這件事了，結果到週末難得可以出去玩，卻又不知道該去哪裡。 travelTube 讓使用者可以記錄自己會想去的地方，做成卡片；或者是在動態牆上看看、用 tag 查詢其他人的卡片，並加以保存。<br />

[<img src="https://github.com/ryhryh/OhPa/blob/refactor/Screenshot/DownloadAppStoreBadge.png" width="150" height="50">](https://itunes.apple.com/tw/app/traveltube/id1390545841?mt=8)


# Screenshot
<p>用標籤搜尋文章、留言與保存文章、新增文章</p>

<img src="https://github.com/ji3g4kami/travelTube/blob/master/screenshots/findArticle.gif" width="252" height="442"> <img src="https://github.com/ji3g4kami/travelTube/blob/master/screenshots/commentAndPreserve.gif" width="252" height="442"> <img src="https://github.com/ji3g4kami/travelTube/blob/master/screenshots/postArticle.gif" width="252" height="442"> 


# Video Demo
[新增貼文](https://www.youtube.com/watch?v=r9dLFk6IZnQ)
[編輯與刪除貼文](https://www.youtube.com/watch?v=ARJ4lQ29ev4&feature=youtu.be)
[搜尋並收藏貼文](https://www.youtube.com/watch?v=O7NFEdgFdAw&feature=youtu.be)


# Featrue
* 登入
	* google 登入
	* 匿名登入：只可遠觀而不能褻玩焉

* 動態時報
	* 新的文章都會進到這裡
	* 點擊右上角的搜尋，看以搜尋到含有此標籤的文章
	* 點擊貼文可以進入去看文章細節
	* 點擊愛心可以儲存；儲存的文章會放在個人頁面

* 文章
	* 點擊地圖可以看到影片相關的地理位置，並且可以開地圖做路線規劃
	* 文章只有原作者可以修改或刪除
	* 文章底下可以留言
	* 自己的留言可以進行編輯或刪除
	* 他人的留言可以進行檢舉
  
* 發布文章
	* 文章是由 Youtube 影片、地標以及貼文組成
	* 地標可以新增多個
	* tag 可以新增至多三個

* 個人頁面
	* 看自己過去的貼文
	* 看搜集的他人貼文

# YouTube Search Enigine
如果是 Clone / Fork 這份專案，記得要新增全域變數的 [youtubeAPIKey](https://console.developers.google.com/apis/credentials)，否則新增貼文時會拿不到 Youtube 的資料
<img src="https://github.com/ji3g4kami/travelTube/blob/master/screenshots/api.jpg" width="692" height="60">

# Library
* YouTubePlayer
* YoutubeEngine
* SwiftLint
* Firebase/Core
* Firebase/Invites
* SDWebImage
* IQKeyboardManagerSwift
* Firebase/Auth
* FirebaseDatabase
* GoogleSignIn
* SKActivityIndicatorView
* CodableFirebase
* Firebase/Storage
* TagListView
* KSTokenView
* Fabric
* Crashlytics


# Requirement
* iOS 11.0+
* Xcode 9.2+


# Contacts
Deng-Li Wu <br />
ji3g4kami@gmail.com 
