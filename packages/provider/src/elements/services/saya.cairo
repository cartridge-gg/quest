use provider::elements::services::interface::ServiceTrait;

impl Saya of ServiceTrait {
    fn version() -> felt252 {
        '1.0.1'
    }
}