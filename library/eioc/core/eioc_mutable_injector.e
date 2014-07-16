note
	description: "Mutable injector allowing to provide singletons and factories."
	author: "Victorien Elvinger"
	date: "$Date$"
	revision: "$Revision$"

class
	EIOC_MUTABLE_INJECTOR

inherit

	EIOC_INJECTOR
		redefine
			default_create
		end

inherit {NONE}

	REFLECTOR
		redefine
			default_create
		end

create
	default_create

feature {NONE} -- Creation

	default_create
			-- Create a default injector.
		do
			create factories.make (20)
		end

feature -- Access (Instance)

	maybe_instance (a_abstraction: TYPE [detachable ANY]): detachable ANY
			-- <Precursor>
		do
			if attached factories.item (type_of_type (attached_type (a_abstraction.type_id))) as l_factory then
				Result := instance_from (l_factory)
			end
		end

	instance (a_abstraction: TYPE [ANY]): ANY
			-- <Precursor>
		do
			if attached factories.item (a_abstraction) as l_factory then
				Result := instance_from (l_factory)
			else
				check instance_exists: False then end
					-- Given by precondition `registered'.
			end
		end

	instance_from (a_factory: FUNCTION [ANY, TUPLE, ANY]): ANY
			-- <Precursor>
		do
			if a_factory.open_count = 0 then
				Result := a_factory (Void)
			else
				Result := a_factory (dependencies (a_factory))
			end
		end

feature -- Access (Factory)

	maybe_item (a_abstraction: TYPE [ANY]): detachable FUNCTION [ANY, TUPLE, ANY]
			-- Factory attached to `a_abstraction',
			-- or Void if `a_abstraction' is not registered.
		do
			Result := factories.item (a_abstraction)
		ensure
			has_a_abstraction_equivalence: has (a_abstraction) = (Result /= Void)
			conforming_types: Result /= Void implies
					{ISE_RUNTIME}.type_conforms_to (Result.generating_type.generic_parameter_type (3).type_id, a_abstraction.type_id)
		end

	item (a_abstraction: TYPE [ANY]): FUNCTION [ANY, TUPLE, ANY]
			-- Factory attached to `a_abstraction'.
		require
			registered: has (a_abstraction)
		do
			if attached maybe_item (a_abstraction) as l_factory then
				Result := l_factory
			else
				check has_factory: False then end
					-- Given by `registered'.
			end
		ensure
			conforming_types: {ISE_RUNTIME}.type_conforms_to (Result.generating_type.generic_parameter_type (3).type_id, a_abstraction.type_id)
		end

feature -- Status report

	has (a_abstraction: TYPE [detachable ANY]): BOOLEAN
			-- <Precursor>
		do
			if a_abstraction.is_attached or a_abstraction.is_expanded then
				Result := factories.has (a_abstraction)
			else
				Result := True
			end
		end

	can_satisfy (a_factory: FUNCTION [ANY, TUPLE, ANY]): BOOLEAN
			-- <Precursor>
		local
			l_type: TYPE [detachable ANY]
		do
			l_type := a_factory.generating_type.generic_parameter_type (2)
			Result := across 1 |..| l_type.generic_parameter_count as it all has (l_type.generic_parameter_type (it.item)) end
		end

feature -- Extension (Factory)

	extend (a_factory: FUNCTION [ANY, TUPLE, ANY])
			-- <Precursor>
		require
			unregistered: not has (a_factory.generating_type.generic_parameter_type (3))
			resolvable: can_satisfy (a_factory)
		do
			factories.put (a_factory, a_factory.generating_type.generic_parameter_type (3))
		ensure
			inserted: attached {TYPE [ANY]} a_factory.generating_type.generic_parameter_type (3) as l_result_type and then
					maybe_item (l_result_type) = a_factory
		end

	put (a_factory: FUNCTION [ANY, TUPLE, ANY]; a_abstraction: TYPE [ANY])
			-- Attach `a_factory' with `a_abstraction'.
		require
			unregistered: not has (a_abstraction)
			resolvable: can_satisfy (a_factory)
			conforming_types: {ISE_RUNTIME}.type_conforms_to (a_factory.generating_type.generic_parameter_type (3).type_id, a_abstraction.type_id)
		do
			factories.put (a_factory, a_abstraction)
		ensure
			inserted: maybe_item (a_abstraction) = a_factory
		end

feature -- Extension (Singleton)

	extend_with_singleton (a_singleton: ANY)
			-- Attach `a_singleton' with its type.
		require
			unregistered: not has (type_of_type (attached_type (a_singleton.generating_type.type_id)))
		do
			factories.put (agent identity (a_singleton), type_of_type (attached_type (a_singleton.generating_type.type_id)))
		ensure
			registered: has (a_singleton.generating_type)
		end

	put_singleton (a_singleton: ANY; a_abstraction: TYPE [ANY])
			-- Attach `a_singleton' with `a_abstraction'.
		require
			unregistered: not has (a_abstraction)
			conforming_types: {ISE_RUNTIME}.type_conforms_to (a_singleton.generating_type.type_id, a_abstraction.type_id)
		do
			put (agent identity (a_singleton), a_abstraction)
		ensure
			inserted: attached maybe_item (a_abstraction) as l_factory and then l_factory.item (Void) = a_singleton
		end

feature {NONE} -- Implementation

	factories: HASH_TABLE [FUNCTION [ANY, TUPLE, ANY], TYPE [detachable ANY]]
			-- Types to factories.

	frozen identity (a_value: ANY): ANY
			-- `a_value'.
		do
			Result := a_value
		ensure
			is_a_value: Result = a_value
		end

	dependencies (a_factory: FUNCTION [ANY, TUPLE, ANY]): TUPLE
			-- Tuple of instance matching with dependency types.
		require
			resolvable: can_satisfy (a_factory)
		local
			l_maybe_optional: TYPE [detachable ANY]
			l_injected: SPECIAL [detachable ANY]
		do
			if attached {TYPE [detachable TUPLE]} a_factory.generating_type.generic_parameter_type (2) as l_dependencies then
				create l_injected.make_empty (l_dependencies.generic_parameter_count)
				across
					1 |..| l_dependencies.generic_parameter_count as it
				loop
					l_maybe_optional := l_dependencies.generic_parameter_type (it.item)
					if attached {TYPE [ANY]} l_maybe_optional as l_dependency then
						l_injected.extend (instance (l_dependency))
					else
						l_injected.extend (maybe_instance (l_maybe_optional))
					end
				end

				if attached new_tuple_from_special (detachable_type (l_dependencies.type_id), l_injected) as l_operands then
					Result := l_operands
				else
					check special_to_tuple: False then end
						-- Given by loop.
				end
			else
				check factory_is_a_function: False then end
					-- Given by `storage'.
			end
		end

end
