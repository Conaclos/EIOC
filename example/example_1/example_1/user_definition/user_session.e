note
	description: "Summary description for {USER_SESSION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	USER_SESSION

inherit

	FRAMEWORK_SESSION

create
	make

feature -- Other

	process
		do
			logger.print (id)
		end

end
