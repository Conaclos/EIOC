note
	description: "Summary description for {FRAMEWORK_APPLICATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	FRAMEWORK_APPLICATION

inherit

	ANY
		redefine
			default_create
		end

feature -- Creation

	default_create
		do
			create injector
		end

feature -- Other

	frozen process
		do
			injector.extend (agent new_dispatcher)
			if attached {FRAMEWORK_DISPATCHER} injector.instance ({FRAMEWORK_DISPATCHER}) as l_dispacher then
				l_dispacher.process
			else
				check instance_exists: False then end
			end
		end

feature {NONE} -- Implementatin

	injector: EIOC_MUTABLE_INJECTOR
			-- Dependency injector.

	new_dispatcher (a_session_factory: FUNCTION [ANY, TUPLE [STRING_8], FRAMEWORK_SESSION]; a_input: STD_FILES): FRAMEWORK_DISPATCHER
		do
			create Result.make (a_session_factory, a_input)
		end

end
