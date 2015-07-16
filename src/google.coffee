# From npm: node-google, conveted to CoffeeScript and modified.

cheerio = require 'cheerio'
request = require 'request'
qs = require 'querystring'

linkSel = 'h3.r a'
descSel = 'div.s'
itemSel = 'li.g'
nextSel = 'td.b a span'

numPerPage = 5

exports.google = (query, callback, start) ->
	start = 0 if !start?

	options =
		# Note: Since ipv6 addresses are abundant, so we use IPv6 here. Should be customizable
		url: "https://ipv6.google.com/search?hl=en&q=#{qs.escape query}&num=#{numPerPage}&start=#{start}"
		method: 'GET'
	
	request options, (err, res, body) =>
		if !err and res.statusCode == 200
			console.log body
			$ = cheerio.load body
			links = []

			for elem, i in $(itemSel)
				linkElem = $(elem).find linkSel
				descElem = $(elem).find descSel

				item =
					title: $(linkElem).first().text()

				qsObj = qs.parse $(linkElem).attr 'href'

				item.link = qsObj['/url?q'] if qsObj['/url?q']

				$(descElem).find('div').remove()

				item.desc = $(descElem).text()

				links.push item

			console.log links

			if $(nextSel).last().text() == 'Next'
				callback links, start + numPerPage
			else
				callback links
		else
			callback()
