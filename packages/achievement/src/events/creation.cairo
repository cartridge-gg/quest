// Internal imports

use achievement::events::index::AchievementCreation;
use achievement::constants;

// Errors

pub mod errors {
    pub const ACHIEVEMENT_INVALID_NAMESPACE: felt252 = 'Achievement: invalid namespace';
    pub const ACHIEVEMENT_INVALID_ACHIEVEMENT: felt252 = 'Achievement: invalid id';
    pub const ACHIEVEMENT_INVALID_TITLE: felt252 = 'Achievement: invalid title';
}

// Implementations

#[generate_trait]
impl AchievementCreationImpl of AchievementCreationTrait {
    #[inline]
    fn new(
        namespace: felt252,
        identifier: felt252,
        hidden: bool,
        points: u16,
        total: u32,
        title: ByteArray,
        hidden_title: ByteArray,
        description: ByteArray,
        hidden_description: ByteArray,
        image_uri: ByteArray,
        icon: felt252,
        time: u64,
    ) -> AchievementCreation {
        // [Check] Inputs
        // [Info] We don't check points here, leave free the game to decide
        AchievementCreationAssert::assert_valid_namespace(namespace);
        AchievementCreationAssert::assert_valid_identifier(identifier);
        AchievementCreationAssert::assert_valid_title(@title);
        // [Return] Achievement
        AchievementCreation {
            namespace,
            identifier,
            hidden,
            points,
            total,
            title,
            hidden_title,
            description,
            hidden_description,
            image_uri,
            icon,
            time
        }
    }
}

#[generate_trait]
impl AchievementCreationAssert of AssertTrait {
    #[inline]
    fn assert_valid_namespace(namespace: felt252) {
        assert(namespace != 0, errors::ACHIEVEMENT_INVALID_NAMESPACE);
    }

    #[inline]
    fn assert_valid_identifier(identifier: felt252) {
        assert(identifier != 0, errors::ACHIEVEMENT_INVALID_ACHIEVEMENT);
    }

    #[inline]
    fn assert_valid_title(title: @ByteArray) {
        assert(title.len() > 0, errors::ACHIEVEMENT_INVALID_TITLE);
    }
}

#[cfg(test)]
mod tests {
    // Local imports

    use super::AchievementCreationTrait;

    // Constants

    const NAMESPACE: felt252 = 'NAMESPACE';
    const IDENTIFIER: felt252 = 'ACHIEVEMENT';
    const HIDDEN: bool = false;
    const POINTS: u16 = 100;
    const TOTAL: u32 = 100;
    const ICON: felt252 = 'ICON';

    #[test]
    fn test_achievement_creation_new() {
        let achievement = AchievementCreationTrait::new(
            NAMESPACE,
            IDENTIFIER,
            HIDDEN,
            POINTS,
            TOTAL,
            "TITLE",
            "HIDDEN_TITLE",
            "DESCRIPTION",
            "HIDDEN_DESCRIPTION",
            "IMAGE_URI",
            ICON,
            1000000000,
        );
        assert_eq!(achievement.namespace, NAMESPACE);
        assert_eq!(achievement.identifier, IDENTIFIER);
        assert_eq!(achievement.hidden, HIDDEN);
        assert_eq!(achievement.points, POINTS);
        assert_eq!(achievement.total, TOTAL);
        assert_eq!(achievement.title, "TITLE");
        assert_eq!(achievement.hidden_title, "HIDDEN_TITLE");
        assert_eq!(achievement.description, "DESCRIPTION");
        assert_eq!(achievement.hidden_description, "HIDDEN_DESCRIPTION");
        assert_eq!(achievement.image_uri, "IMAGE_URI");
        assert_eq!(achievement.icon, ICON);
        assert_eq!(achievement.time, 1000000000);
    }

    #[test]
    #[should_panic(expected: ('Achievement: invalid namespace',))]
    fn test_achievement_creation_new_invalid_namespace() {
        AchievementCreationTrait::new(
            0,
            IDENTIFIER,
            HIDDEN,
            POINTS,
            TOTAL,
            "TITLE",
            "HIDDEN_TITLE",
            "DESCRIPTION",
            "HIDDEN_DESCRIPTION",
            "IMAGE_URI",
            ICON,
            1000000000
        );
    }

    #[test]
    #[should_panic(expected: ('Achievement: invalid id',))]
    fn test_achievement_creation_new_invalid_identifier() {
        AchievementCreationTrait::new(
            NAMESPACE,
            0,
            HIDDEN,
            POINTS,
            TOTAL,
            "TITLE",
            "HIDDEN_TITLE",
            "DESCRIPTION",
            "HIDDEN_DESCRIPTION",
            "IMAGE_URI",
            ICON,
            1000000000
        );
    }

    #[test]
    #[should_panic(expected: ('Achievement: invalid title',))]
    fn test_achievement_creation_new_invalid_title() {
        AchievementCreationTrait::new(
            NAMESPACE,
            IDENTIFIER,
            HIDDEN,
            POINTS,
            TOTAL,
            "",
            "HIDDEN_TITLE",
            "DESCRIPTION",
            "HIDDEN_DESCRIPTION",
            "IMAGE_URI",
            ICON,
            1000000000
        );
    }
}

