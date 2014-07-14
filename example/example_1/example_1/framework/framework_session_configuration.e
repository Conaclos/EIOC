note
	description: "Summary description for {FRAMEWORK_SESSION_CONFIGURATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FRAMEWORK_SESSION_CONFIGURATION

create
	make
	
feature -- Creation

	make (a_timeout: like timeout)
			-- Create with `a_timeout' as `timeout'.
		do
			timeout := a_timeout
		ensure
			timeout_set: timeout = a_timeout
		end

feature -- Access

	timeout: INTEGER
			-- Session timeout.

end
