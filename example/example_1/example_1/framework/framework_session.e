note
	description: "Summary description for {FRAMEWORK_SESSION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	FRAMEWORK_SESSION

feature {NONE} -- Creation

	make (a_id: STRING_8; a_logger: STD_FILES; a_configuration: FRAMEWORK_SESSION_CONFIGURATION)
			-- Create a default session.
		do
			id := a_id
			configuration := a_configuration
			logger := a_logger
		ensure
			id_set: id = a_id
			configuration_set: configuration = a_configuration
			logger_set: logger = a_logger
		end

feature -- Other

	process
			-- Session processing.
		deferred end

feature -- Access

	id: STRING_8
			-- Session id.

	configuration: FRAMEWORK_SESSION_CONFIGURATION
			-- Session configuration.

	logger: STD_FILES
			-- Session logger.

end
