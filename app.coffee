
console.time 'StartServer'
console.time 'requireLib'
#=======[LIBRARY CONNECTION]========
express = require 'express'
multer  = require 'multer'
bodyParser = require 'body-parser'
path = require 'path'
multer = require 'path'
mongojs = require 'mongojs'
app = express()

#----------[EJS CONNECTION]---------
ejs = require('ais-ejs-mate')({ open: '{{', close:'}}'})
#-----------------------------------

###------------------------------
| # Description : Database (Configuration & Setup)
| # Latest update by @primayudantra - Oct 8, 2015
* -------------------------------------------- ###
setipeDBurl = "setipe"
collection_user = "user"
collection_match = "matching"

dbSetipe = mongojs('127.0.0.1/' + setipeDBurl)
#----------------------------------

app.use bodyParser()
app.engine '.html', ejs

app.set('views',__dirname);
app.set 'views', "./views"
app.set 'view engine', 'html'

###------------------------------
| Description : set assets in folder assets include js, css & media
| Latest Update by @primayudantra - Oct 8, 2015
-------------------------------###
app.use(express.static(__dirname + '/assets'));

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

app.get '/data-user', (req, res) ->
	res.render 'data-user'

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

app.get '/test', (req,res) ->
	user_id = req.params._id
	name = req.params.name
	dbSetipe.collection(collection_user).find {_id: mongojs.ObjectId(user_id)}, (error, result) ->
		data =
			dataJson: result
		console.log data
		res.render 'plain_prima', data


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

