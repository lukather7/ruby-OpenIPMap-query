require 'json'
require 'net/https'  
require 'open-uri'

class OpenIPMapQuery
	def new
		@query_template= 'https://marmot.ripe.net/openipmap/ipmeta.json?ip=%s'
		@result = nil
		@have_result = false
		@Debug = false
	end

	def setDebug
		@Debug = true
  end

	def unsetDebug
		@Debug = false
  end

	def query(ip)
		p ip if (@Debug == true)
		rv = {'lat' => nil, 'lon' => nil, 'city' => nil}
		@query_template= 'https://marmot.ripe.net/openipmap/ipmeta.json?ip='
		begin
			locinfo = open(@query_template + ip, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
			locjson = JSON.parse(locinfo)
			p locjson if (@Debug == true)
			loc = locjson['crowdsourced'][0]
			if (loc.length > 0) 
				if ((loc['lat'] != nil) && (loc['lon'] != nil)) 
					rv['lat'] = loc['lat']
					rv['lon'] = loc['lon']
				end
				if (loc['canonical_georesult'] != nil) 
					rv['city'] = loc['canonical_georesult']
				end
			end
		rescue
			STDERR.printf("problem in loading routergeoloc for ip: %s\n", ip)
		end
		return rv
	end

end

if $0 == __FILE__
	oim = OpenIPMapQuery.new

#	oim.setDebug

	for ip in ARGV
		res = oim.query(ip)
		printf "%s\t%s\n", ip, res.to_s
	end
end
