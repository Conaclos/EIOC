note
	description: "Read-only injector."
	author: "Victorien Elvinger"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EIOC_INJECTOR

feature -- Access (Instance)

	maybe_instance (a_abstraction: TYPE [detachable ANY]): detachable ANY
			-- Instance of type `a_abstraction'.
			--
			-- Will be made obsolete when Eiffel typing context will be available.
			-- `instance'will be then more permissive.
			-- Use `instance' instead if possible.
		require
			attached_abstraction_implication: (a_abstraction.is_attached or a_abstraction.is_expanded) implies has (a_abstraction)
		deferred
		ensure
			attached_abstraction_result_implication: (a_abstraction.is_attached or a_abstraction.is_expanded) implies (Result /= Void)
		end

	instance (a_abstraction: TYPE [ANY]): ANY
			-- Instance of type `a_abstraction'.
			--
			-- Future signature: instance (a_abstraction: TYPE [?]): ?
		require
			registered: has (a_abstraction)
		deferred end

	instance_from (a_factory: FUNCTION [ANY, TUPLE, ANY]): ANY
			-- Use `a_factory' for reslt creation
			--
			-- Future signature: instance (a_factory: FUNCTION [ANY, TUPLE, ?]): ?
		require
			resolvable: can_satisfy (a_factory)
		deferred end

feature -- Status report

	has (a_abstraction: TYPE [detachable ANY]): BOOLEAN
			-- Has a factory attached to `a_abstraction'?
		deferred
		ensure
			detachable_type_implication: (not (a_abstraction.is_attached or a_abstraction.is_expanded)) implies Result
		end

	can_satisfy (a_factory: FUNCTION [ANY, TUPLE, ANY]): BOOLEAN
			-- Has dependencies of `a_factory'?
		deferred end

end
