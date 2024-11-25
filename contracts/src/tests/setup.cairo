mod setup {
    // Core imports

    use core::debug::PrintTrait;

    // Starknet imports

    use starknet::ContractAddress;
    use starknet::testing;
    use starknet::testing::{set_caller_address, set_contract_address, set_block_timestamp};

    // Dojo imports

    use dojo::world::{WorldStorage, WorldStorageTrait};
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, ContractDef, TestResource, ContractDefTrait,
        WorldStorageTestTrait
    };

    // External imports

    use controller::models::{index as controller_models};
    use provider::models::{index as provider_models};
    use registry::models::{index as registry_models};
    use society::models::{index as society_models};
    use society::events::{index as society_events};
    use achievement::events::{index as achievement_events};

    // Internal imports

    use arcade::constants::NAMESPACE;
    use arcade::systems::pinner::{Pinner, IPinnerDispatcher};
    use arcade::systems::registry::{Registry, IRegistryDispatcher};
    use arcade::systems::slot::{Slot, ISlotDispatcher};
    use arcade::systems::society::{Society, ISocietyDispatcher};
    use arcade::systems::wallet::{Wallet, IWalletDispatcher};

    // Constant

    fn OWNER() -> ContractAddress {
        starknet::contract_address_const::<'OWNER'>()
    }

    fn PLAYER() -> ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[derive(Copy, Drop)]
    struct Systems {
        pinner: IPinnerDispatcher,
        registry: IRegistryDispatcher,
        slot: ISlotDispatcher,
        society: ISocietyDispatcher,
        wallet: IWalletDispatcher,
    }

    #[derive(Copy, Drop)]
    struct Context {
        player_id: felt252,
    }

    #[inline]
    fn setup_namespace() -> NamespaceDef {
        NamespaceDef {
            namespace: NAMESPACE(), resources: [
                TestResource::Model(controller_models::m_Account::TEST_CLASS_HASH),
                TestResource::Model(controller_models::m_Controller::TEST_CLASS_HASH),
                TestResource::Model(controller_models::m_Signer::TEST_CLASS_HASH),
                TestResource::Model(provider_models::m_Deployment::TEST_CLASS_HASH),
                TestResource::Model(provider_models::m_Factory::TEST_CLASS_HASH),
                TestResource::Model(provider_models::m_Team::TEST_CLASS_HASH),
                TestResource::Model(provider_models::m_Teammate::TEST_CLASS_HASH),
                TestResource::Model(registry_models::m_Access::TEST_CLASS_HASH),
                TestResource::Model(registry_models::m_Achievement::TEST_CLASS_HASH),
                TestResource::Model(registry_models::m_Game::TEST_CLASS_HASH),
                TestResource::Model(society_models::m_Alliance::TEST_CLASS_HASH),
                TestResource::Model(society_models::m_Guild::TEST_CLASS_HASH),
                TestResource::Model(society_models::m_Member::TEST_CLASS_HASH),
                TestResource::Event(society_events::e_Follow::TEST_CLASS_HASH),
                TestResource::Event(achievement_events::e_TrophyPinning::TEST_CLASS_HASH),
                TestResource::Contract(Pinner::TEST_CLASS_HASH),
                TestResource::Contract(Registry::TEST_CLASS_HASH),
                TestResource::Contract(Slot::TEST_CLASS_HASH),
                TestResource::Contract(Society::TEST_CLASS_HASH),
                TestResource::Contract(Wallet::TEST_CLASS_HASH),
            ].span()
        }
    }

    fn setup_contracts() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@NAMESPACE(), @"Pinner")
                .with_writer_of([dojo::utils::bytearray_hash(@NAMESPACE())].span()),
            ContractDefTrait::new(@NAMESPACE(), @"Registry")
                .with_writer_of([dojo::utils::bytearray_hash(@NAMESPACE())].span())
                .with_init_calldata(array![OWNER().into()].span()),
            ContractDefTrait::new(@NAMESPACE(), @"Slot")
                .with_writer_of([dojo::utils::bytearray_hash(@NAMESPACE())].span())
                .with_init_calldata(array![].span()),
            ContractDefTrait::new(@NAMESPACE(), @"Society")
                .with_writer_of([dojo::utils::bytearray_hash(@NAMESPACE())].span()),
            ContractDefTrait::new(@NAMESPACE(), @"Wallet")
                .with_writer_of([dojo::utils::bytearray_hash(@NAMESPACE())].span()),
        ].span()
    }

    #[inline]
    fn spawn() -> (WorldStorage, Systems, Context) {
        // [Setup] World
        set_contract_address(OWNER());
        let namespace_def = setup_namespace();
        let world = spawn_test_world([namespace_def].span());
        world.sync_perms_and_inits(setup_contracts());
        // [Setup] Systems
        let (pinner_address, _) = world.dns(@"Pinner").unwrap();
        let (registry_address, _) = world.dns(@"Registry").unwrap();
        let (slot_address, _) = world.dns(@"Slot").unwrap();
        let (society_address, _) = world.dns(@"Society").unwrap();
        let (wallet_address, _) = world.dns(@"Wallet").unwrap();
        let systems = Systems {
            pinner: IPinnerDispatcher { contract_address: pinner_address },
            registry: IRegistryDispatcher { contract_address: registry_address },
            slot: ISlotDispatcher { contract_address: slot_address },
            society: ISocietyDispatcher { contract_address: society_address },
            wallet: IWalletDispatcher { contract_address: wallet_address },
        };

        // [Setup] Context
        let context = Context { player_id: PLAYER().into() };

        // [Return]
        (world, systems, context)
    }
}