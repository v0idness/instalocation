module EventsHelper
	#convert the plain links into HTML anchor links (with <a> tags) and return the string back
  	#uses String's gsub method for regular expression
  	def display_with_links(text)
    	text.gsub(/(http:\/\/[a-zA-Z0-9\/\.\+\-_:?&=]+)/) {|a| "<a href=\"#{a}\">#{a}</a>"}
  	end

  	def display_truncated_no_links(text)
    	text = text.gsub(/(http:\/\/[a-zA-Z0-9\/\.\+\-_:?&=]+)/) {|a| ""}
    	if text.length > 70 then
    		text = text[0...70]
    		text << "..."
    	else
    		text = text[0...70]
    	end
  	end
end
