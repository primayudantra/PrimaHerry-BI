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
	res.render 'plain_prima'
