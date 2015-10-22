
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

###------------------------------
| ROUTER for Data User
| Method : GET
| Latest update by @primayudantra - Oct 22, 2015
* ------------------------------###
app.get '/data-user', (req, res) ->
	db.collection(collection_user).find {}, (error, result) ->
		data = 
			name : req.body.name
			email : req.body.email
			password : req.body.password
			age : req.body.age
			gender : req.body.gender
			total_match : req.body.total_match
			dataJson : result
		res.render 'data-user', data

###------------------------------
| ROUTER for Data User
| Method : GET
| Latest update by @primayudantra - Oct 8, 2015
* ------------------------------###

app.get '/newsignup', (req, res) ->
	res.render 'newsignup'

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
port = 8800
app.listen port, ()->
	console.log "App Running on"
	console.log "localhost:" + port

