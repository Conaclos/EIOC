note
	description: "Read-only injector."
	author: "Victorien Elvinger"

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
			is_obtainable: is_obtainable (a_abstraction)
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
			-- Use `a_factory' for result creation.
			--
			-- Future signature: instance (a_factory: FUNCTION [ANY, TUPLE, ?]): ?
		require
			resolvable: can_satisfy (a_factory)
		deferred end

feature -- Status report

	has (a_abstraction: TYPE [detachable ANY]): BOOLEAN
			-- Has a factory attached to `a_abstraction'?
			--
			-- Attachment mark is not considered.
		deferred
		end

	is_obtainable (a_abstraction: TYPE [detachable ANY]): BOOLEAN
			-- Is an instance of `a_abstraction' obtainable?
			-- An instance of a detachable reference type is always obtainable (Void).
		do
			Result := not (a_abstraction.is_attached or a_abstraction.is_expanded) or has (a_abstraction)
		ensure
			detachable_reference_type_is_obtainable: (not (a_abstraction.is_attached or a_abstraction.is_expanded)) implies Result
			not_detachable_reference_type_implication: (a_abstraction.is_attached or a_abstraction.is_expanded) implies Result = has (a_abstraction)
		end

	can_satisfy (a_factory: FUNCTION [ANY, TUPLE, ANY]): BOOLEAN
			-- Has dependencies of `a_factory'?
		local
			l_type: TYPE [detachable ANY]
		do
			l_type := a_factory.generating_type.generic_parameter_type (2)
			Result := across 1 |..| l_type.generic_parameter_count as it all is_obtainable (l_type.generic_parameter_type (it.item)) end
		end

end
