note
	description: "Summary description for {FRAMEWORK_DISPATCHER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FRAMEWORK_DISPATCHER

create
	make

feature {NONE} -- Creation

	make (a_session_factory: like session_factory; a_input: STD_FILES)
			-- Crate a default session listener.
		do
			session_factory := a_session_factory
			input := a_input
		ensure
			session_factory_set: session_factory = a_session_factory
			input_set: input = a_input
		end

feature -- Other

	process
			-- Listen and lauch new sessions.
		do
			across
				1 |..| 3 as it
			loop
				input.read_word
				session_factory (input.last_string).process
			end
		end

feature -- Access

	session_factory: FUNCTION [ANY, TUPLE [id: STRING_8], FRAMEWORK_SESSION]
			-- Session factory.

	input: STD_FILES
			-- Input.

end
