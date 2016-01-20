console.time 'StartServer'
console.time 'requireLib'
#=======[LIBRARY CONNECTION]========
http 			= require 'http'
express 		= require 'express'
multer  		= require 'multer'
bodyParser 		= require 'body-parser'
path 			= require 'path'
multer 			= require 'multer'
mongojs 		= require 'mongojs'
util 			= require 'util'
client 			= require 'node-rest-client'
request 		= require 'request'
async 			= require 'async'
CryptoJS		= require 'crypto-js'
crypto 			= require 'crypto'
passport 		= require 'passport'
LocalStrategy 	= require 'passport-local'
# ---------------------------------------- passport testing
app = express()
cookieParser 	= require 'cookie-parser'
cookieSession 	= require 'cookie-session'
expressSession 	= require 'express-session'
RedisStore 		= require('connect-redis') expressSession

###-- Passport JS --###


###------------------------------
| # Description : Database (Configuration & Setup)
| # Latest update by @primayudantra - Oct 8, 2015
* -------------------------------------------- ###
setipeDBurl =  "db-thesis" #"setipe"
collection_user = "user" #"user"
collection_admin = "admin"
collection_analyticalReport = "analyticReport"
collection_matching	= "matching"
collection_messages = "messages"
collection_androidReport = "androidReport"
collection_iOSReport = "iOSReport"
collection_signinReport = "signinMonth"
collection_emailrule = "emailRule"
collection_emailTemp = "emailTemplate"
collection_notif = "notifToUser"
#----------[EJS CONNECTION]---------
ejs = require('ais-ejs-mate')({ open: '{{', close:'}}'})
#-----------------------------------

# db = mongojs('127.0.0.1/' + setipeDBurl)
db = mongojs 'db-thesis', ['admin']

#----------------------------------
#	SETUP PASSPORT
#---------------------------------- 
# passport.use new LocalStrategy(
# 	(email, password, done) ->
# 		db.admin.find {email : email}, (err, user) ->
# 			return done err if err
# 			return done null, false, { message: 'Incorrect email'} if not user
# 			return done null, false, { message: 'Incorrect password'} if password is not user.password
# 			return done null, user
# 	)
passport.use new LocalStrategy({
		usernameField : 'email'
		passwordField : 'password'
		},
		(email, password, done) ->
	  		db.admin.findOne { email : email }, (err, user) ->
			    if err
			    	return done err
			    if not email
			    	console.log "User not found " + email
			    if not password
			    	console.log "Password not found " + password
			    else 
			    	console.log "correct"
			    	return done null, user
	)
#----------------------------------
#	SETUP EXPRESS
#---------------------------------- 
app.engine '.html', ejs
app.use bodyParser()
app.use bodyParser.urlencoded({extended: false})
app.use bodyParser.json()

app.set('views',__dirname);
app.use(express.static(__dirname + '/assets'));

sessionStoreOpts = new RedisStore
	db : 1
	prefix: 'sess:'

expressSessionOpts =
	store: sessionStoreOpts
	secret: 'hae'
	saveUninitialized: true
	resave: true
	cookie:
		secure: false
		maxAge: 60 * 60 * 1000

app.use expressSession expressSessionOpts
app.use passport.initialize()
app.use passport.session()

passport.serializeUser (user, done) ->
	done null, user

passport.deserializeUser (user, done) ->
	db.admin.findOne {email : user.email}, (err, user)->
		done err, user

# For Sessions
# app.use (req,res,next) ->
# 	req.user = {}
# 	req.user.job = 'business'
# 	next()
	
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

app.get '/login',(req,res) ->
	res.render 'login'

###------------------------------
| ROUTER Login Page
| Method : POST
| Latest update by @primayudantra - November 14, 2015
* ------------------------------###

app.post '/login', passport.authenticate('local',
	successRedirect: '/home' 
	failureRedirect: '/login' 
	failureFlash: true)

app.get '/testAuth', (req,res) ->
	console.log "Masuk"
	return res.redirect 'login' if not req.user
	res.json { message: 'success', user: req.user}

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
		# password : crypto.createHash("sha256").update(req.body.password).digest("hex")
		password : req.body.password
		job : req.body.job
	console.dir data
	db.collection(collection_admin).save data, (error, result) ->
		if error
			return res.send(error)
		# alert "Registration Success"
		res.render "login"
		next()

###------------------------------
| ROUTER Register Page
| Method : Get
| Latest update by @primayudantra - November 12, 2015
* ------------------------------###
app.get '/logout', (req, res, next) ->
	req.logout()
	res.redirect '/login'

###------------------------------
| ROUTER PAGE
| Author : @primayudantra
| Latest update by @primayudantra - Nov 28, 2015
* ------------------------------###

app.get '/', (req, res) ->
	return res.redirect '/login' if not req.user
	res.redirect '/home'

###------------------------------
| ROUTER and CONTROLLER for home
| Method : GET
| Latest update by @primayudantra - Nov 12, 2015
* ------------------------------###
app.get '/home',(req, res) ->
	data = {}
	async.parallel {
		userCount: (cb)->
			db.collection(collection_user).count {}, cb
		userCountMale: (cb) ->
			db.collection(collection_user).count {"gender" : "male"}, cb
		userCountFemale: (cb) ->
			db.collection(collection_user).count {"gender" : "female"}, cb
		messagesCount: (cb) ->
			db.collection(collection_messages).count {}, cb
		matchCount: (cb) ->
			db.collection(collection_matching).count {}, cb
		androidCount: (cb) ->
			db.collection(collection_androidReport).count {}, cb
		iosCount: (cb) ->
			db.collection(collection_iOSReport).count {}, cb
	}, (err, {userCount, userCountMale,userCountFemale,messagesCount,matchCount,androidCount,iosCount}) ->
		if err
			return next err
		data.user 				= req.user
		data.userCount 			= userCount
		data.userCountMale 		= userCountMale
		data.userCountFemale 	= userCountFemale
		data.messagesCount		= messagesCount
		data.matchCount			= matchCount
		data.androidCount		= androidCount
		data.iosCount			= iosCount
		data.totalApps 			= androidCount + iosCount
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
		# console.log data
		res.render 'emailrule', data


app.post '/emailrule', (req, res)->
	id_rules = req.body.id_rules
	actionType = req.body.actionType
	if actionType == 'Delete'
		db.collection(collection_emailrule).remove { _id: mongojs.ObjectId(id_rules)},true,(err, result) ->
			console.log "Data was Deleted"
			res.redirect 'emailrule'

app.get '/update-emailrule-:id', (req, res)->
	id = req.params.id
	console.log id
	db.collection(collection_emailrule).find { _id: mongojs.ObjectId(id)}, (err, result) ->
		db.collection(collection_emailTemp).find (err, result_temp) ->
			data = 
				dataJson : result
				emailTemp : result_temp
			data.user = req.user
			console.log data
			res.render 'emailrule-update', data

app.post '/update-emailrule-:id', (req, res, next)->
	id = req.params.id
	rulesname : req.body.new_rulesname
	template : req.body.new_template
	query : req.body.new_query
	schedule : req.body.new_schedule
	engine : req.body.new_engine

	updateObject =
		name : req.body.new_rulesname
		template : req.body.new_template
		query : req.body.new_query
		schedule : req.body.new_schedule
		engine : req.body.new_engine
	# db.collection(collection_formpage).update { _id: mongojs.ObjectId(id_rules) }, { $set: updateObject }, (error, result) ->	
	console.log updateObject
	db.collection(collection_emailrule).update {_id:mongojs.ObjectId(id)}, {$set: updateObject},(err, result) ->
		if err
			console.dir err
		else
			console.log "Data was updated"
		res.redirect 'emailrule'

app.get '/input-emailrule', (req, res) ->
	db.collection(collection_emailTemp).find (err, result) ->
		data =
			emailTemp : result
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
		db.collection(collection_emailTemp).count (err, countresult) ->
			data =
				emailTempNo : countresult
				emailTemp : result
			data.user = req.user
			res.render 'emailtemplate', data

app.post '/emailtemplate', (req, res) ->
	id_temp = req.body.id_temp
	actionType = req.body.actionType

	if actionType == 'Delete'
		db.collection(collection_emailTemp).remove {_id : mongojs.ObjectId(id_temp)}, true,(err, result) ->
			console.log "Data Was Deleted"
			res.redirect 'emailtemplate'

app.get '/input-emailtemplate', (req,res) ->
	data = {}
	data.user = req.user
	res.render 'emailtemplateinput', data

app.get '/update-emailtemplate-:id', (req,res) ->
	id = req.params.id
	console.log id
	db.collection(collection_emailTemp).find {_id : mongojs.ObjectId(id)}, (err, result)->
		data =
			dataJson : result
		data.user = req.user
		res.render 'emailtemplate-update', data

app.post '/update-emailtemplate-:id', (req, res) ->
	id = req.params.id
	template_name : req.body.template_name
	email_subject : req.body.email_subject
	email_type : req.body.email_type
	email_file : req.body.email_file
	email_content : req.body.email_content

	updateObject =
		template_name : req.body.template_name
		email_subject : req.body.email_subject
		email_type : req.body.email_type
		email_file : req.body.email_file
		email_content : req.body.email_content

	console.log updateObject
	db.collection(collection_emailTemp).update {_id:mongojs.ObjectId(id)}, {$set: updateObject},(err, result) ->
		if err
			console.dir err
		else
			console.log "Data was updated"
		res.redirect 'emailtemplate'


app.post '/input-emailtemplate', multer(dest: './uploads/').single('email-file'), (req, res, next) ->
	data =
		template_name : req.body.template_name
		email_subject : req.body.email_subject
		email_type : req.body.email_type
		email_file : req.body.email_file
		email_content : req.body.email_content
	console.dir data
	db.collection(collection_emailTemp).save data, (err, result) ->
		if err
			console.dir err
		else
			console.log "DB Inserted"
			next()
	data.user = req.user
	res.redirect 'input-emailtemplate'

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

app.get '/notification-update-:id', (req, res) ->
	id = req.params.id
	console.log id
	db.collection(collection_notif).find { _id: mongojs.ObjectId(id)}, (err, result) ->
		data = 
			dataJson : result
		data.user = req.user
		console.log data
		res.render 'notification-update', data
		
app.post '/notification-update-:id', (req, res)->
	id = req.params.id
	target_user : req.body.target_user
	typenotif	: req.body.typeNotif
	content		: req.body.content
	date 		: req.body.date
	# 
	updateObject =
		target_user : req.body.target_user
		typenotif	: req.body.typeNotif
		content		: req.body.content
		date 		: req.body.date
	console.log updateObject

	db.collection(collection_notif).update {_id:mongojs.ObjectId(id)}, {$set: updateObject},(err, result) ->
		if err
			console.dir err
		else
			console.log "Data was updated"
		res.redirect '/notification'

app.post '/notification', (req,res) ->
	id_notif = req.body.id_notif
	actionType = req.body.actionType

	if actionType == "Delete"
		db.collection(collection_notif).remove { _id:mongojs.ObjectId(id_notif)}, (err,result) ->
			console.log "Data was Deleted"
			res.redirect 'notification'


app.get '/input-notification', (req, res) ->
	data = {}
	data.user = req.user
	res.render 'notificationinput', data

app.post '/input-notification', (req,res,next)->
	data =
		target_user : req.body.target_user
		typenotif	: req.body.typeNotif
		content		: req.body.content
		date 		: req.body.date
	console.log data
	data.user = req.username
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
