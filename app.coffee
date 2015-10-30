
console.time 'StartServer'
console.time 'requireLib'
#=======[LIBRARY CONNECTION]========
express = require 'express'
multer  = require 'multer'
bodyParser = require 'body-parser'
path = require 'path'
multer = require 'path'
mongojs = require 'mongojs'

###------------------------------
| # Description : Database (Configuration & Setup)
| # Latest update by @primayudantra - Oct 8, 2015
* -------------------------------------------- ###
setipeDBurl =  "db-thesis" #"setipe"
collection_user = "user" #"user"
collection_analyticalReport = "analyticReport"


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

app.set 'views', "./views"
app.set 'view engine', 'html'

###------------------------------
| ROUTER PAGE
| Author : @primayudantra & @herrycriestian
| Latest update by @primayudantra - Oct 8, 2015
* ------------------------------###

app.get '/', (req, res) ->
	res.render 'index'

app.get '/login', (req,res) ->
	res.render 'login'

app.get '/home', (req,res) ->
	res.render 'index'

#----------DATA USER---------------

###------------------------------
| ROUTER and CONTROLLER for Data User
| Method : GET
| Latest update by @primayudantra - Oct 22, 2015
* ------------------------------###
app.get '/data-user', (req, res) ->
	# db.collection(collection_user).count "gender" : "male", cb, (error, result) ->
	# 	totalval_male = result.male
	db.collection(collection_user).find {}, (error,result) ->
		db.collection(collection_user).count {"gender" : "female"}, (error, resultFemale) ->
			db.collection(collection_user).count {"gender" : "male"}, (error, resultMale) ->
				data = 
					dataJson : result
					countFemale : resultFemale
					countMale : resultMale

				if error
					console.dir error
				console.dir data
				res.render 'data-user', data

###------------------------------
| Edit and Delete Function for Data User
| Method : Post
| Latest update by @primayudantra - Oct 27, 2015
* ------------------------------###
app.post '/data-user', (req, res) ->
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
		console.dir data
		res.render 'analytic-report', data

###------------------------------
| ROUTER for Data User
| Method : GET
| Latest update by @primayudantra - Oct 8, 2015
* ------------------------------###
app.get '/data-signup', (req, res) ->
	db.collection(collection_analyticalReport).find {}, (error, result) ->
		data =
			countAnalytic : result
		res.render 'data-signup', data

app.get '/data-match', (req,res) ->
	res.render 'data-match'

app.get '/most-match', (req,res) ->
	res.render 'most-match'

app.get '/zero-match', (req,res) ->
	res.render 'zero-match'

app.get '/data-messages', (req,res) ->
	res.render 'data-messages'

app.get '/most-messages', (req,res) ->
	res.render 'most-messages'

app.get '/zero-messages', (req, res) ->
	res.render 'zero-messages'

app.get '/report',(req,res) ->
	res.render 'report'

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
