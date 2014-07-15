note
	description: "Tests for {EIOC_MUTABLE_INJECTOR}."
	author: "Victorien Elvinger"
	date: "$Date$"
	revision: "$Revision$"
    testing: "type/manual", "covers/{EIOC_MUTABLE_INJECTOR}"

class
	EIOC_MUTABLE_INJECTOR_TEST

inherit

	EQA_TEST_SET

feature -- Test

	test_has
		note
			testing:  "covers/{EIOC_MUTABLE_INJECTOR}.has"
		local
			l_injector: EIOC_MUTABLE_INJECTOR
			l_type: TYPE [like new_cell]
		do
			create l_injector

			l_type := {like new_cell}
			assert ("factory for " + l_type.name + " is not registered.", not l_injector.has (l_type))

			l_injector.extend (agent new_cell)
			assert ("factory for " + l_type.name + " exists.", l_injector.has (l_type))
		end

	test_can_satisfy
			-- Test factory with optional dependency, non-optional dependency and without dependency.
		note
			testing:  "covers/{EIOC_MUTABLE_INJECTOR}.can_satisfy"
		local
			l_injector: EIOC_MUTABLE_INJECTOR
		do
			create l_injector

			assert ("Factory routine without dependencies is satisfied.", l_injector.can_satisfy (agent new_cell))

			assert ("Factory with only optional dependencies is satisfied.", l_injector.can_satisfy (agent new_arrayed_list_from))

			assert ("Factory with unregistered dependencies cannot be satisfied.", not l_injector.can_satisfy (agent new_list_from_cell))

			l_injector.extend (agent new_cell)
			assert ("Factory with registered dependencies is satisfied.", l_injector.can_satisfy (agent new_list_from_cell))
		end

	test_maybe_instance
		note
			testing:  "covers/{EIOC_MUTABLE_INJECTOR}.maybe_instance"
		local
			l_injector: EIOC_MUTABLE_INJECTOR
			l_any: detachable ANY
		do
			create l_injector

			l_any := l_injector.maybe_instance ({detachable like new_cell})
			assert ("Instance for an unregistered abstraction is Void.", l_any = Void)

			l_injector.extend (agent new_cell)
			l_any := l_injector.maybe_instance ({detachable like new_cell})
			assert ("Instance for a registered abstraction attached to a factory without dependencies has the exepcted type.", attached {like new_cell} l_any)

			l_injector.extend (agent new_arrayed_list_from)
			l_any := l_injector.maybe_instance ({detachable like new_arrayed_list_from})
			assert ("Instance for a registered abstraction attached to a factory with only optional dependencies has the exepcted type.", attached {like new_arrayed_list_from} l_any)

			l_injector.extend (agent new_list_from_cell)
			l_any := l_injector.maybe_instance ({detachable like new_list_from_cell})
			assert ("Instance for a registered abstraction attached to a factory with registered dependencies has the exepcted type.", attached {like new_list_from_cell} l_any)
			assert ("Instance for a registered abstraction attached to a factory with registered dependencies has the exepcted result.", attached {like new_list_from_cell} l_any as l_list and then not l_list.is_empty and then l_list [1] ~ new_cell.item)

			l_any := l_injector.maybe_instance ({detachable like new_arrayed_list_from})
		end

	test_put
		note
			testing:  "covers/{EIOC_MUTABLE_INJECTOR}.put"
		local
			l_injector: EIOC_MUTABLE_INJECTOR
			l_any: detachable ANY
			l_type: TYPE [ANY]
		do
			create l_injector

			l_type := {like new_cell}
			l_injector.put (agent new_cell, l_type) -- equivalent to extend (agent new_cell)
			assert ("Factory for " + l_type.name + " is registered.", l_injector.has (l_type))

			l_type := {LIST [STRING_8]}
			l_injector.put (agent new_list_from_cell, l_type)
			assert ("Factory for " + l_type.name + " is registered.", l_injector.has (l_type))
			l_any := l_injector.maybe_instance (l_type)
			assert ("Instance for a registered abstraction different of the factory result ype has the expected type.", attached {LIST [STRING_8]} l_any)
		end

	test_singleton
		note
			testing:  "covers/{EIOC_MUTABLE_INJECTOR}.extend_with_singleton"
		local
			l_injector: EIOC_MUTABLE_INJECTOR
			l_singleton: like new_cell
			l_singleton_type: TYPE [like new_cell]
		do
			create l_injector

			l_singleton := new_cell
			l_singleton_type := {like new_cell}

			l_injector.extend_with_singleton (l_singleton)
			assert ("Singletion keep reference transparency.", l_injector.maybe_instance (l_singleton_type) = l_singleton)
		end


feature {NONE} -- Data

	new_cell: CELL [STRING_8]
			-- Cell containing a welcome text.
		do
			create Result.put ("Hello World!")
		end

	new_list_from_cell (a_cell: CELL [STRING_8]): LINKED_LIST [STRING_8]
			-- List from `a_cell'.
		do
			create Result.make
			Result.extend (a_cell.item)
		end

	new_arrayed_list_from (a_list: detachable LIST [STRING_8]): ARRAYED_LIST [STRING_8]
			-- Arrayed list from `a_list'
		do
			create Result.make (2)
			if a_list /= Void then
				across
					a_list as it
				loop
					Result.extend (it.item)
				end
			end
		end

end
