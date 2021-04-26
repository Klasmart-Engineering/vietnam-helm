ALTER TABLE `home_fun_studies` DROP INDEX `home_fun_studies_schedule_id`;

ALTER TABLE `home_fun_studies` DROP INDEX `home_fun_studies_status`;

ALTER TABLE `home_fun_studies` DROP INDEX `home_fun_studies_latest_feedback_at`;

ALTER TABLE `home_fun_studies` ADD UNIQUE INDEX `uq_home_fun_studies_schedule_id_and_student_id`(`schedule_id`, `student_id`) USING BTREE;

ALTER TABLE `home_fun_studies` ADD INDEX `idx_home_fun_studies_schedule_id`(`schedule_id`) USING BTREE;

ALTER TABLE `home_fun_studies` ADD INDEX `idx_home_fun_studies_status`(`status`) USING BTREE;

ALTER TABLE `home_fun_studies` ADD INDEX `idx_home_fun_studies_complete_at`(`latest_feedback_at`) USING BTREE;


ALTER TABLE `learning_outcomes` ADD FULLTEXT INDEX `fullindex_name`(`name`);

ALTER TABLE `learning_outcomes` ADD FULLTEXT INDEX `fullindex_keywords`(`keywords`);

ALTER TABLE `learning_outcomes` ADD FULLTEXT INDEX `fullindex_shortcode`(`shortcode`);

ALTER TABLE `learning_outcomes` ADD FULLTEXT INDEX `fullindex_description`(`description`);

ALTER TABLE `organizations_properties` ADD COLUMN `region` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'region' AFTER `delete_at`;

CREATE TABLE `organizations_regions`  (
  `id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'id',
  `headquarter` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT 'headquarter',
  `organization_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT 'organization_id',
  `create_at` bigint NULL DEFAULT 0 COMMENT 'created_at',
  `update_at` bigint NULL DEFAULT 0 COMMENT 'updated_at',
  `delete_at` bigint NULL DEFAULT 0 COMMENT 'delete_at',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `organization_regions_headquarter_index`(`headquarter`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'organization_regions' ROW_FORMAT = Dynamic;

CREATE TABLE `outcomes_sets`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `outcome_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'outcome_id',
  `set_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'set_id',
  `create_at` bigint NOT NULL DEFAULT 0 COMMENT 'created_at',
  `update_at` bigint NOT NULL DEFAULT 0 COMMENT 'updated_at',
  `delete_at` bigint NULL DEFAULT NULL COMMENT 'deleted_at',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `outcome_set_id_delete`(`outcome_id`, `set_id`, `delete_at`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'outcomes_sets' ROW_FORMAT = Dynamic;

CREATE TABLE `programs_groups`  (
  `program_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'program id',
  `group_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'group name',
  PRIMARY KEY (`program_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'programs groups' ROW_FORMAT = Dynamic;

CREATE TABLE `sets`  (
  `id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'id',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'name',
  `organization_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'organization_id',
  `create_at` bigint NOT NULL DEFAULT 0 COMMENT 'created_at',
  `update_at` bigint NOT NULL DEFAULT 0 COMMENT 'updated_at',
  `delete_at` bigint NULL DEFAULT NULL COMMENT 'deleted_at',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `index_name`(`name`) USING BTREE,
  FULLTEXT INDEX `fullindex_name`(`name`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'sets' ROW_FORMAT = Dynamic;

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac1c69c02dddf234c95b4', '5fdac0f61f066722a1351adb', 'developmental2', 'skills7');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac1ff68a1a1ca0e48cb38', '5fdac0f61f066722a1351adb', 'developmental5', 'skills14');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac1ff68a1a1ca0e48cb39', '5fdac0f61f066722a1351adb', 'developmental5', 'skills15');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac275ae478ff90653f646', '5fdac06ea878718a554ff00d', 'developmental1', 'skills1');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac275ae478ff90653f647', '5fdac06ea878718a554ff00d', 'developmental1', 'skills2');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac275ae478ff90653f648', '5fdac06ea878718a554ff00d', 'developmental1', 'skills3');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac285ae478ff90653f64b', '5fdac06ea878718a554ff00d', 'developmental2', 'skills7');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac291ae478ff90653f64e', '5fdac06ea878718a554ff00d', 'developmental3', 'skills9');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac2a3ae478ff90653f651', '5fdac06ea878718a554ff00d', 'developmental4', 'skills12');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac2bdae478ff90653f654', '5fdac06ea878718a554ff00d', 'developmental5', 'skills14');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac2bdae478ff90653f655', '5fdac06ea878718a554ff00d', 'developmental5', 'skills15');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac38349757bb8ed19dbf0', '5fdac0f61f066722a1351adb', 'developmental1', 'skills3');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac38349757bb8ed19dbf1', '5fdac0f61f066722a1351adb', 'developmental1', 'skills42');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac38349757bb8ed19dbf2', '5fdac0f61f066722a1351adb', 'developmental1', 'skills41');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac38349757bb8ed19dbf3', '5fdac0f61f066722a1351adb', 'developmental1', 'skills40');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac38349757bb8ed19dbf4', '5fdac0f61f066722a1351adb', 'developmental1', 'skills39');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac38349757bb8ed19dbf5', '5fdac0f61f066722a1351adb', 'developmental1', 'skills38');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac38349757bb8ed19dbf6', '5fdac0f61f066722a1351adb', 'developmental1', 'skills20');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac38349757bb8ed19dbf7', '5fdac0f61f066722a1351adb', 'developmental1', 'skills37');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3a63f1e0c8bda5749bd', '5fdac0f61f066722a1351adb', 'developmental3', 'skills9');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3a63f1e0c8bda5749be', '5fdac0f61f066722a1351adb', 'developmental3', 'skills10');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3a63f1e0c8bda5749bf', '5fdac0f61f066722a1351adb', 'developmental3', 'skills11');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3f13f1e0c8bda5749c2', '5fdac0f61f066722a1351adb', 'developmental4', 'skills37');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3f13f1e0c8bda5749c3', '5fdac0f61f066722a1351adb', 'developmental4', 'skills20');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3f13f1e0c8bda5749c4', '5fdac0f61f066722a1351adb', 'developmental4', 'skills38');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3f13f1e0c8bda5749c5', '5fdac0f61f066722a1351adb', 'developmental4', 'skills39');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3f13f1e0c8bda5749c6', '5fdac0f61f066722a1351adb', 'developmental4', 'skills40');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3f13f1e0c8bda5749c7', '5fdac0f61f066722a1351adb', 'developmental4', 'skills41');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3f13f1e0c8bda5749c8', '5fdac0f61f066722a1351adb', 'developmental4', 'skills42');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac3f13f1e0c8bda5749c9', '5fdac0f61f066722a1351adb', 'developmental4', 'skills3');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4696b7a4c3c14177ff4', '5fdac0fe1f066722a1351ade', 'developmental1', 'skills40');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4696b7a4c3c14177ff5', '5fdac0fe1f066722a1351ade', 'developmental1', 'skills41');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4696b7a4c3c14177ff6', '5fdac0fe1f066722a1351ade', 'developmental1', 'skills42');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4786b7a4c3c14177ffb', '5fdac0fe1f066722a1351ade', 'developmental2', 'skills7');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4786b7a4c3c14177ffc', '5fdac0fe1f066722a1351ade', 'developmental2', 'skills8');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac48e6b7a4c3c14177fff', '5fdac0fe1f066722a1351ade', 'developmental3', 'skills9');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac48e6b7a4c3c14178000', '5fdac0fe1f066722a1351ade', 'developmental3', 'skills10');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac48f6b7a4c3c14178001', '5fdac0fe1f066722a1351ade', 'developmental3', 'skills11');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4af6b7a4c3c14178009', '5fdac0fe1f066722a1351ade', 'developmental4', 'skills40');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4af6b7a4c3c1417800a', '5fdac0fe1f066722a1351ade', 'developmental4', 'skills41');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4af6b7a4c3c1417800b', '5fdac0fe1f066722a1351ade', 'developmental4', 'skills42');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4af6b7a4c3c1417800c', '5fdac0fe1f066722a1351ade', 'developmental4', 'skills43');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4c76b7a4c3c1417800f', '5fdac0fe1f066722a1351ade', 'developmental5', 'skills14');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdac4c76b7a4c3c14178010', '5fdac0fe1f066722a1351ade', 'developmental5', 'skills15');

INSERT INTO `developments_skills` (`id`, `program_id`, `development_id`, `skill_id`) VALUES ('5fdace48842bcaf37f169bbb', '5fd9ddface9660cbc5f667d8', 'developmental0', 'skills0');

INSERT INTO `organizations_properties` (`id`, `type`, `created_id`, `updated_id`, `deleted_id`, `created_at`, `updated_at`, `delete_at`, `region`) VALUES ('9d42af2a-d943-4bb7-84d8-9e2e28b0e290', 'headquarters', NULL, NULL, NULL, 0, 0, 0, 'vn');

UPDATE `organizations_properties` SET `type` = 'headquarters', `created_id` = NULL, `updated_id` = NULL, `deleted_id` = NULL, `created_at` = 0, `updated_at` = 0, `delete_at` = 0, `region` = 'global' WHERE `id` = '10f38ce9-5152-4049-b4e7-6d2e2ba884e6';

INSERT INTO `organizations_regions` (`id`, `headquarter`, `organization_id`, `create_at`, `update_at`, `delete_at`) VALUES ('5fb24528993e7591084c2c46', '9d42af2a-d943-4bb7-84d8-9e2e28b0e290', '281e49c6-a1f8-4d5e-83f2-0cf76700601c', 1615963415, 1615963415, 0);

INSERT INTO `programs` (`id`, `name`, `number`, `org_type`, `group_name`, `create_id`, `update_id`, `delete_id`, `create_at`, `update_at`, `delete_at`) VALUES ('5fd9ddface9660cbc5f667d8', 'None Specified', 1000, 'normal', NULL, '64a36ec1-7aa2-53ab-bb96-4c4ff752096b', '', '', 1608113658, 0, 0);

INSERT INTO `programs` (`id`, `name`, `number`, `org_type`, `group_name`, `create_id`, `update_id`, `delete_id`, `create_at`, `update_at`, `delete_at`) VALUES ('5fdac06ea878718a554ff00d', 'ESL', 0, 'normal', NULL, '64a36ec1-7aa2-53ab-bb96-4c4ff752096b', '', '', 1608171630, 0, 0);

INSERT INTO `programs` (`id`, `name`, `number`, `org_type`, `group_name`, `create_id`, `update_id`, `delete_id`, `create_at`, `update_at`, `delete_at`) VALUES ('5fdac0f61f066722a1351adb', 'Math', 0, 'normal', NULL, '64a36ec1-7aa2-53ab-bb96-4c4ff752096b', '', '', 1608171766, 0, 0);

INSERT INTO `programs` (`id`, `name`, `number`, `org_type`, `group_name`, `create_id`, `update_id`, `delete_id`, `create_at`, `update_at`, `delete_at`) VALUES ('5fdac0fe1f066722a1351ade', 'Science', 0, 'normal', NULL, '64a36ec1-7aa2-53ab-bb96-4c4ff752096b', '', '', 1608171774, 0, 0);

UPDATE `programs` SET `name` = 'None Specified', `number` = 1000, `org_type` = 'headquarters', `group_name` = NULL, `create_id` = NULL, `update_id` = NULL, `delete_id` = NULL, `create_at` = 0, `update_at` = 0, `delete_at` = 0 WHERE `id` = 'program0';

UPDATE `programs` SET `name` = 'Bada Talk', `number` = 0, `org_type` = 'headquarters', `group_name` = 'BadaESL', `create_id` = '', `update_id` = '64a36ec1-7aa2-53ab-bb96-4c4ff752096b', `delete_id` = '', `create_at` = 0, `update_at` = 1605515152, `delete_at` = 0 WHERE `id` = 'program1';

UPDATE `programs` SET `name` = 'Bada Math', `number` = 0, `org_type` = 'headquarters', `group_name` = 'BadaSTEAM', `create_id` = '', `update_id` = '64a36ec1-7aa2-53ab-bb96-4c4ff752096b', `delete_id` = '', `create_at` = 0, `update_at` = 1605841394, `delete_at` = 0 WHERE `id` = 'program2';

UPDATE `programs` SET `name` = 'Bada STEM', `number` = 0, `org_type` = 'headquarters', `group_name` = 'BadaSTEAM', `create_id` = NULL, `update_id` = NULL, `delete_id` = NULL, `create_at` = 0, `update_at` = 0, `delete_at` = 0 WHERE `id` = 'program3';

UPDATE `programs` SET `name` = 'Bada Genius', `number` = 0, `org_type` = 'headquarters', `group_name` = 'BadaESL', `create_id` = '', `update_id` = '64a36ec1-7aa2-53ab-bb96-4c4ff752096b', `delete_id` = '', `create_at` = 0, `update_at` = 1605514594, `delete_at` = 0 WHERE `id` = 'program4';

UPDATE `programs` SET `name` = 'Bada Read', `number` = 0, `org_type` = 'headquarters', `group_name` = 'BadaESL', `create_id` = '', `update_id` = '64a36ec1-7aa2-53ab-bb96-4c4ff752096b', `delete_id` = '', `create_at` = 0, `update_at` = 1605515005, `delete_at` = 0 WHERE `id` = 'program5';

UPDATE `programs` SET `name` = 'Bada Sound', `number` = 0, `org_type` = 'headquarters', `group_name` = 'BadaESL', `create_id` = '', `update_id` = '64a36ec1-7aa2-53ab-bb96-4c4ff752096b', `delete_id` = '', `create_at` = 0, `update_at` = 1605515107, `delete_at` = 0 WHERE `id` = 'program6';

UPDATE `programs` SET `name` = 'Bada Rhyme', `number` = 0, `org_type` = 'headquarters', `group_name` = 'BadaESL', `create_id` = NULL, `update_id` = NULL, `delete_id` = NULL, `create_at` = 0, `update_at` = 0, `delete_at` = 0 WHERE `id` = 'program7';

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac2e2ae478ff90653f661', '5fdac0f61f066722a1351adb', 'age1');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac2e2ae478ff90653f662', '5fdac0f61f066722a1351adb', 'age2');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac2e2ae478ff90653f663', '5fdac0f61f066722a1351adb', 'age3');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac2e2ae478ff90653f664', '5fdac0f61f066722a1351adb', 'age4');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac2e2ae478ff90653f665', '5fdac0f61f066722a1351adb', 'age5');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac2eeae478ff90653f669', '5fdac06ea878718a554ff00d', 'age1');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac2eeae478ff90653f66a', '5fdac06ea878718a554ff00d', 'age2');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac2eeae478ff90653f66b', '5fdac06ea878718a554ff00d', 'age3');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac2eeae478ff90653f66c', '5fdac06ea878718a554ff00d', 'age4');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac4133f1e0c8bda5749ce', '5fdac0fe1f066722a1351ade', 'age1');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac4133f1e0c8bda5749cf', '5fdac0fe1f066722a1351ade', 'age2');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac4133f1e0c8bda5749d0', '5fdac0fe1f066722a1351ade', 'age3');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac4133f1e0c8bda5749d1', '5fdac0fe1f066722a1351ade', 'age4');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdac4133f1e0c8bda5749d2', '5fdac0fe1f066722a1351ade', 'age5');

INSERT INTO `programs_ages` (`id`, `program_id`, `age_id`) VALUES ('5fdace28842bcaf37f169ba8', '5fd9ddface9660cbc5f667d8', 'age0');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac1831f066722a1351aff', '5fdac0f61f066722a1351adb', 'developmental1');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac1831f066722a1351b00', '5fdac0f61f066722a1351adb', 'developmental2');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac1831f066722a1351b01', '5fdac0f61f066722a1351adb', 'developmental3');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac1831f066722a1351b02', '5fdac0f61f066722a1351adb', 'developmental4');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac1831f066722a1351b03', '5fdac0f61f066722a1351adb', 'developmental5');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac25649757bb8ed19dbe0', '5fdac06ea878718a554ff00d', 'developmental1');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac25649757bb8ed19dbe1', '5fdac06ea878718a554ff00d', 'developmental2');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac25649757bb8ed19dbe2', '5fdac06ea878718a554ff00d', 'developmental3');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac25649757bb8ed19dbe3', '5fdac06ea878718a554ff00d', 'developmental4');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac25649757bb8ed19dbe4', '5fdac06ea878718a554ff00d', 'developmental5');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac44d3f1e0c8bda5749e2', '5fdac0fe1f066722a1351ade', 'developmental1');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac44d3f1e0c8bda5749e3', '5fdac0fe1f066722a1351ade', 'developmental2');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac44d3f1e0c8bda5749e4', '5fdac0fe1f066722a1351ade', 'developmental3');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac44d3f1e0c8bda5749e5', '5fdac0fe1f066722a1351ade', 'developmental4');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdac44d3f1e0c8bda5749e6', '5fdac0fe1f066722a1351ade', 'developmental5');

INSERT INTO `programs_developments` (`id`, `program_id`, `development_id`) VALUES ('5fdace3f842bcaf37f169bb6', '5fd9ddface9660cbc5f667d8', 'developmental0');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac1431f066722a1351aec', '5fdac06ea878718a554ff00d', 'grade2');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac1431f066722a1351aed', '5fdac06ea878718a554ff00d', 'grade3');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac1431f066722a1351aee', '5fdac06ea878718a554ff00d', 'grade12');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac1431f066722a1351aef', '5fdac06ea878718a554ff00d', 'grade5');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac30bae478ff90653f672', '5fdac0f61f066722a1351adb', 'grade7');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac30bae478ff90653f673', '5fdac0f61f066722a1351adb', 'grade8');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac30bae478ff90653f674', '5fdac0f61f066722a1351adb', 'grade9');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac30bae478ff90653f675', '5fdac0f61f066722a1351adb', 'grade10');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac30bae478ff90653f676', '5fdac0f61f066722a1351adb', 'grade11');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac4273f1e0c8bda5749d6', '5fdac0fe1f066722a1351ade', 'grade7');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac4273f1e0c8bda5749d7', '5fdac0fe1f066722a1351ade', 'grade8');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac4273f1e0c8bda5749d8', '5fdac0fe1f066722a1351ade', 'grade9');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac4273f1e0c8bda5749d9', '5fdac0fe1f066722a1351ade', 'grade10');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdac4273f1e0c8bda5749da', '5fdac0fe1f066722a1351ade', 'grade11');

INSERT INTO `programs_grades` (`id`, `program_id`, `grade_id`) VALUES ('5fdace2f842bcaf37f169bae', '5fd9ddface9660cbc5f667d8', 'grade0');

INSERT INTO `programs_groups` (`program_id`, `group_name`) VALUES ('4591423a-2619-4ef8-a900-f5d924939d02', 'BadaSTEAM');

INSERT INTO `programs_groups` (`program_id`, `group_name`) VALUES ('56e24fa0-e139-4c80-b365-61c9bc42cd3f', 'BadaESL');

INSERT INTO `programs_groups` (`program_id`, `group_name`) VALUES ('7565ae11-8130-4b7d-ac24-1d9dd6f792f2', 'More');

INSERT INTO `programs_groups` (`program_id`, `group_name`) VALUES ('7a8c5021-142b-44b1-b60b-275c29d132fe', 'BadaESL');

INSERT INTO `programs_groups` (`program_id`, `group_name`) VALUES ('93f293e8-2c6a-47ad-bc46-1554caac99e4', 'BadaESL');

INSERT INTO `programs_groups` (`program_id`, `group_name`) VALUES ('b39edb9a-ab91-4245-94a4-eb2b5007c033', 'BadaESL');

INSERT INTO `programs_groups` (`program_id`, `group_name`) VALUES ('d1bbdcc5-0d80-46b0-b98e-162e7439058f', 'BadaSTEAM');

INSERT INTO `programs_groups` (`program_id`, `group_name`) VALUES ('f6617737-5022-478d-9672-0354667e0338', 'BadaESL');

INSERT INTO `programs_subjects` (`id`, `program_id`, `subject_id`) VALUES ('5fdac1591f066722a1351af3', '5fdac06ea878718a554ff00d', 'subject1');

INSERT INTO `programs_subjects` (`id`, `program_id`, `subject_id`) VALUES ('5fdac31aae478ff90653f67c', '5fdac0f61f066722a1351adb', 'subject2');

INSERT INTO `programs_subjects` (`id`, `program_id`, `subject_id`) VALUES ('5fdac4303f1e0c8bda5749de', '5fdac0fe1f066722a1351ade', 'subject3');

INSERT INTO `programs_subjects` (`id`, `program_id`, `subject_id`) VALUES ('5fdace37842bcaf37f169bb2', '5fd9ddface9660cbc5f667d8', 'subject0');
