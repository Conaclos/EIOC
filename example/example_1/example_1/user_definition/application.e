note
	description : "example_1 application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	FRAMEWORK_APPLICATION

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		do
			default_create
			injector.extend_with_singleton (io)
			injector.extend_with_singleton (create {FRAMEWORK_SESSION_CONFIGURATION}.make (100))

			injector.extend (agent session_factory_provider)

			process
		end

	session_factory_provider (a_logger: STD_FILES; a_configuration: FRAMEWORK_SESSION_CONFIGURATION): FUNCTION [ANY, TUPLE [STRING_8], FRAMEWORK_SESSION]
			-- Session factory provider.
		do
			Result := agent (a1_id: STRING_8; a1_logger: STD_FILES; a1_configuration: FRAMEWORK_SESSION_CONFIGURATION): USER_SESSION
				do
					create Result.make (a1_id, a1_logger, a1_configuration)
				end (?, a_logger, a_configuration)
		end

end
