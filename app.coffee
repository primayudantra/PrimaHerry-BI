console.time 'StartServer'
console.time 'requireLib'
#=======[LIBRARY CONNECTION]========
http 		= require 'http'
express 	= require 'express'
multer  	= require 'multer'
bodyParser 	= require 'body-parser'
path 		= require 'path'
multer 		= require 'multer'
mongojs 	= require 'mongojs'
util 		= require 'util'
client 		= require 'node-rest-client'
request 	= require 'request'
async 		= require 'async'
CryptoJS	= require 'crypto-js'
crypto 		= require 'crypto'

###-- Passport JS --###
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy

###------------------------------
| # Description : Database (Configuration & Setup)
| # Latest update by @primayudantra - Oct 8, 2015
* -------------------------------------------- ###
setipeDBurl =  "db-thesis" #"setipe"
collection_user = "user" #"user"
collection_analyticalReport = "analyticReport"
collection_matching	= "matching"
collection_messages = "messages"
collection_androidReport = "androidReport"
collection_iOSReport = "iOSReport"
collection_admin = "admin"
collection_signinReport = "signinMonth"
collection_emailrule = "emailRule"
collection_emailTemp = "emailTemplate"
collection_notif = "notifToUser"
#----------[EJS CONNECTION]---------
ejs = require('ais-ejs-mate')({ open: '{{', close:'}}'})
#-----------------------------------

db = mongojs('127.0.0.1/' + setipeDBurl)

#----------------------------------
app = express()
app.engine '.html', ejs
app.use bodyParser()


###------------------------------
| Description : set assets in folder assets include js, css & media
| Latest Update by @primayudantra - Oct 8, 2015
-------------------------------###


app.set('views',__dirname);
app.use(express.static(__dirname + '/assets'));

# For Sessions
app.use (req,res,next) ->
	req.user = {}
	req.user.job = 'marketing'
	next()

app.set 'views', "./views"
app.set 'view engine', 'html'

loginValidation = (req, res, next) ->
	if req.body.name == ''
		console.log "Name must be filled"
	else if req.body.password == ''
		console.log "Password must be filled"
	else if req.body.name == '' and req.body.password == ''
		console.log "Email and Password must be filled"
	else
		next()
# #########
# passport.use new LocalStrategy({
#   username: 'username'
#   password: 'password'
# }, (username, password, done) ->
#   User.find(where: username: username).success((user) ->
#     if !user
#       done null, false, message: 'The user is not exist'
#     else if !hashing.compare(password, user.password)
#       done null, false, message: 'Wrong password'
#     else
#       done null, user
#   ).error (err) ->
#     # if command executed with error
#     done err
#   return

#########

checkAuth = (req, res, next) ->
	if req.query.accessToken and req.query.accessToken != ''
		req.session = {}
		console.dir req.query.accessToken
		req.session.isUser = true;
		next()
	else
		html = '<a href="/login">Login</a>'
		res.send 'You must '+html+' because you dont have a token'

###------------------------------
| ROUTER Secret Page
| Method : Get
| Latest update by @primayudantra - November 14, 2015
* ------------------------------###

app.get '/secret-page', (req, res) ->
	params = {}
	request {
  		url: 'http://localhost:8877/api/admin'
  		method: 'GET'
	}, (err, res, resultAPI) ->
		console.dir resultAPI.data
		# data = 
			# 	result : resultAPI.data
		# console.dir data
	res.send 'You are logged in now'


loginValidation = (req, res, next) ->
	data = 
		username : req.body.username
		password : req.body.password
	if data.username == 'admin' && data.password == 'admin'
		console.log 'Masuk'	
		res.redirect '/home'
	else
		next()

# API for Admin
app.get '/api/admin', (req, res) ->
	db.collection(collection_admin).find {}, (error, result) ->
		data =
			data : result
		console.dir data
		res.json data
###------------------------------
| ROUTER Login Page
| Method : Get
| Latest update by @primayudantra - November 14, 2015
* ------------------------------###


app.get '/login',(req,res) ->
	dataAPI = ''
	# API
	request 'http://localhost:8877/api/admin', (err,res,resultAPI) ->
		if not err and res.statusCode == 200
			dataAPI = resultAPI
		console.log dataAPI
	# END API
	res.render 'login'
###------------------------------
| ROUTER Login Page
| Method : POST
| Latest update by @primayudantra - November 14, 2015
* ------------------------------###

app.post '/login',loginValidation,(req, res) ->
	res.send 'Bad Login'

###------------------------------
| ROUTER Register Page
| Method : Get
| Latest update by @primayudantra - November 12, 2015
* ------------------------------###
app.get '/register', (req, res) ->
	res.render 'register'

###------------------------------
| ROUTER Register Page
| Method : Post
| Latest update by @primayudantra - November 12, 2015
* ------------------------------###
app.post '/register', (req, res, next) ->
	data =
		name : req.body.name
		email : req.body.email
		password : crypto.createHash("sha256").update(req.body.password).digest("hex")
		job : req.body.job
	console.dir data
	db.collection(collection_admin).save data, (error, result) ->
		if error
			return res.send(error)
		# alert "Registration Success"
		res.render "login"
		next()


###------------------------------
| ROUTER PAGE
| Author : @primayudantra
| Latest update by @primayudantra - Nov 28, 2015
* ------------------------------###

app.get '/', (req, res) ->
	res.redirect '/home'

###------------------------------
| ROUTER and CONTROLLER for home
| Method : GET
| Latest update by @primayudantra - Nov 12, 2015
* ------------------------------###
app.get '/home', (req,res) ->
	db.collection(collection_user).count {}, (error, userResult) ->
		db.collection(collection_user).count {"gender" : "male"}, (error, maleResult) ->
			db.collection(collection_user).count {"gender" : "female"}, (error, femaleResult) ->
				db.collection(collection_messages).count {}, (error, messagesResult) ->
					db.collection(collection_matching).count {}, (error, matchingResult) ->
						db.collection(collection_androidReport).count {}, (error, androidResult) ->
							db.collection(collection_iOSReport).count {}, (error, iOSResult) ->
								data =
									countUser : userResult
									countMale : maleResult
									countFemale : femaleResult
									countMessages : messagesResult
									countMatching : matchingResult
									countAndroid : androidResult
									countIOS : iOSResult
									totalapps : androidResult + iOSResult
								if error
									console.dir error
								data.user = req.user
								res.render 'index', data


app.get '/async', (req,res) ->
	data = {}
	async.parallel {
		data1: (cb) ->
			db.collection(collection_user).count {}, cb
		data2: (cb) ->
			db.collection(collection_matching).count {}, cb
	}, (err, { data1, data2 }) ->
		if err
			return next err
		console.dir data
		data.user = req.user
		data.data1 = data1
		data.data2 = data2 
		# res.render "test", data
		res.json data

###------------------------------
| ROUTER and CONTROLLER for Data User
| Method : GET
| Latest update by @primayudantra - Oct 22, 2015
* ------------------------------###
app.get '/data-user', (req, res) ->
	db.collection(collection_user).find {}, (error,result) ->
		db.collection(collection_user).count {"gender" : "female"}, (error, resultFemale) ->
			db.collection(collection_user).count {"gender" : "male"}, (error, resultMale) ->
				data = 
					dataJson : result
					countFemale : resultFemale
					countMale : resultMale

				if error
					console.dir error
				# url = require('/api/data-user')
				data.user = req.user
				res.render 'data-user', data

###------------------------------
| Edit and Delete Function for Data User
| Method : Post
| Latest update by @primayudantra - Oct 27, 2015
* ------------------------------###
app.post '/data-user', (req, res) ->
	data.user = req.user
	userId = req.body.userId
	actionType = req.body.actionType

	if actionType == 'Delete'
		db.collection(collection_user).remove { _id : mongojs.ObjectId(userId) }, true, (error, result) ->
			console.log "Data was deleted"
			res.redirect 'data-user'

#----------ANALYTICAL REPORT---------------
###------------------------------
| ROUTER AND CONTROLLER FOR ANALYTIC REPORT
| Method : GET
| Latest update by @primayudantra - Oct 28, 2015
* ------------------------------###
app.get '/analytic-report', (req, res) ->
	db.collection(collection_analyticalReport).find {}, (error, result) ->
		data =
			countAnalytic : result
		if error
			console.dir error
		# console.dir data
		data.user = req.user
		res.render 'analytic-report', data

###------------------------------
| ROUTER AND CONTROLLER FOR SIGN IN REPORT
| Method : GET
| Latest update by @primayudantra - NOV 12, 2015
* ------------------------------###
app.get '/signin-report', (req, res) ->
	dataAPI = ""
	request 'http://localhost:8877/api/data-signin', (err,res,resultAPI) ->
		if not err and res.statusCode == 200
			dataAPI = resultAPI
			console.dir dataAPI
	db.collection(collection_signinReport).find {}, (err, result) ->
		data =
			countSigninReport : result
		if err
			console.dir err
		data.user = req.user
		res.render 'signin-report', data

app.get '/api/data-signin', (req, res) ->
	db.collection(collection_signinReport).find {}, (err, result) ->
		data =
			data : result
		res.json data

###------------------------------
| ROUTER for Data User
| Method : GET
| Latest update by @primayudantra - Oct 8, 2015
* ------------------------------###
app.get '/data-signup',(req, res) ->
	# dataAPI = ''
	# request 'http://localhost:8877/api/data-analytic' , (err,res,resultAPI) ->
	# 	if not err and res.statusCode == 200
	# 		dataAPI = resultAPI
			# console.dir dataAPI
	db.collection(collection_analyticalReport).find {}, (error, result) ->
		data =
			countAnalytic : result
			# getAPI : dataAPI
		# console.dir data.getAPI
		res.render 'data-signup', data


###------------------------------
| ROUTER for Data Match
| Method : GET
| Latest update by @primayudantra - Nov 6, 2015
* ------------------------------###
app.get '/data-match', (req,res) ->
	db.collection(collection_matching).find {}, (error, result) ->
		data =
			countMatching : result
		data.user = req.user
		res.render 'data-match', data


###------------------------------
| ROUTER for Data Messages
| Method : GET
| Latest update by @primayudantra - Nov 6, 2015
* ------------------------------###
app.get '/data-messages', (req,res) ->
	db.collection(collection_messages).find {}, (error, result) ->
		data =
			countMessages : result
		data.user = req.user
		res.render 'data-messages', data

###------------------------------
| ROUTER for Data User
| Method : GET
| Latest update by @primayudantra - Nov 6, 2015
* ------------------------------###
app.get '/report',(req,res) ->
	res.render 'report'

###------------------------------
| ROUTER and CONTROLLER for Android Report
| Method : GET
| Latest update by @primayudantra - Nov 12, 2015
* ------------------------------###
app.get '/android-report', (req, res) ->
	db.collection(collection_androidReport).find {}, (error, result) ->
		data =
			dataAndroid : result
		data.user = req.user
		res.render 'android-report', data


###------------------------------
| ROUTER and CONTROLLER for IOS Report
| Method : GET
| Latest update by @primayudantra - Nov 12, 2015
* ------------------------------###

app.get '/ios-report', (req,res) ->
	db.collection(collection_iOSReport).find {}, (error, result) ->
		data =
			dataIOS : result
		data.user = req.user
		res.render 'ios-report', data

###------------------------------
| ROUTER for TEST
| Method : GET
| Latest update by @primayudantra - Nov 6, 2015
* ------------------------------###
app.get '/test', (req , res) ->
	db.collection(collection_user).find {}, (error, result) ->
		data = 
			name : req.body.name
			email : req.body.email
			password : req.body.password
			age : req.body.age
			gender : req.body.gender
			total_match : req.body.total_match
			dataJson : result
		console.dir data
		data.user = req.user
		res.render 'plain_prima', data

app.get '/test-form', (req, res) ->
	res.render 'form'

app.post '/test-form', (req, res, next) ->
	# data Testing
	data =
		name : req.body.name
		email : req.body.email
		password : req.body.password
		age : req.body.age
		gender : req.body.gender
		total_match : req.body.total_match
	console.dir data

	db.collection(collection_user).save data, (error, result) ->
		if error
			return res.send(error)
		console.log "Data Masuk"
		res.render "form"
		next()

app.get '/list-rule', (req , res) ->
	db.collection(collection_formpage).find {}, (error, result) ->
		data =
			dataJson: result		
		#console.dir(data)
		res.render 'list-page', data


#-------------- API ---------------
###------------------------------
|	Description : Set Up API for Data User
|	Author : @PrimaYudantra
|	Latest update by @PrimaYudantra - Oct 31, 2015
* -------------------------------------------- ###

app.get '/api/data-user', (req, res) ->
	db.collection(collection_user).find {}, (error, result) ->
		data =
			profile : result
		res.json data

###------------------------------
|	Description : Set Up API for Data Analytic
|	Author : @PrimaYudantra
|	Latest update by @PrimaYudantra - Oct 31, 2015
* -------------------------------------------- ###
app.get '/api/data-analytic', (req, res) ->
	db.collection(collection_analyticalReport).find {}, (error, result) ->
		data =
			data : result
		res.json data

###------------------------------
|	Description : Function watch the list for Email Rule
|	Author : @PrimaYudantra
|	Latest update by @PrimaYudantra - Dec 4, 2015
* -------------------------------------------- ###
app.get '/emailrule', (req, res)->
	db.collection(collection_emailrule).find (err, result) ->
		data =
			emailRule : result
		data.user = req.user
		res.render 'emailrule', data

app.get '/input-emailrule', (req, res) ->
	data = {}
	data.user = req.user
	res.render 'emailruleinput', data

app.post '/input-emailrule', (req, res, next) ->
	data =
		name : req.body.rulesname
		template : req.body.template
		query : req.body.query
		schedule : req.body.schedule
		engine : req.body.engine
	console.dir data
	db.collection(collection_emailrule).save data, (err, result) ->
		if err
			console.dir err
		else
			console.log "Masuk ke DB"
			next()
	res.render 'emailrule', data
###------------------------------
|	Description : Function to watch list email template
|	Author : @PrimaYudantra
|	Latest update by @PrimaYudantra - Dec 14, 2015
* -------------------------------------------- ###
app.get '/emailtemplate', (req, res) ->
	db.collection(collection_emailTemp).find (err, result) ->
		data =
			emailTemp : result
		data.user = req.user
		res.render 'emailtemplate', data

app.get '/input-emailtemplate', (req,res) ->
	data = {}
	data.user = req.user
	res.render 'emailtemplateinput', data

app.post '/input-emailtemplate', multer(dest: './uploads/').single('email-file'), (req, res, next) ->
	data =
		template_name : req.body.template_name
		email_subject : req.body.email_subject
		email_type : req.body.email_type
		email_file : req.body.email_file
		email_content : req.body.email_content
	data.user = req.user
	console.dir data
	db.collection(collection_emailTemp).save data, (err, result) ->
		if err
			console.dir err
		else
			console.log "DB Inserted"
			next()
	res.render 'emailtemplate', data

###------------------------------
|	Description : Notification to User
|	Author : @PrimaYudantra
|	Latest update by @PrimaYudantra - Dec 18, 2015
* -------------------------------------------- ###
app.get '/notification', (req, res) ->
	db.collection(collection_notif).find (err, result) ->
		data =
			notifResult : result
		console.dir data
		data.user = req.user
		res.render 'notification', data

app.get '/input-notification', (req, res) ->
	data = {}
	data.user = req.user
	res.render 'notificationinput'

app.post '/input-notification', (req,res,next)->
	data =
		target_user : req.body.target_user
		typenotif	: req.body.typeNotif
		content		: req.body.content
		date 		: req.body.date
	console.log data
	db.collection(collection_notif).save data , (err, result) ->
		if err
			console.log err
		else
			console.log "Data insert to DB"
			next()
		res.render '/notification', data

#-------------- LOCALHOST ---------------
###------------------------------
|
|	Description : Set Up Localhost
|	Author : @PrimaYudantra
|	Latest update by @PrimaYudantra - Oct 1, 2015
|
* -------------------------------------------- ###
port = 8877
app.listen port, ()->
	console.log "App Running on"
	console.log "localhost:" + port
