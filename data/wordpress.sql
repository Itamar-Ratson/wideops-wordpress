-- phpMyAdmin SQL Dump
-- version 4.6.6deb4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Feb 12, 2018 at 05:08 PM
-- Server version: 10.1.26-MariaDB-0+deb9u1
-- PHP Version: 7.0.27-0+deb9u1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `wordpress`
--

-- --------------------------------------------------------

--
-- Table structure for table `wp_commentmeta`
--

CREATE TABLE `wp_commentmeta` (
  `meta_id` bigint(20) UNSIGNED NOT NULL,
  `comment_id` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wp_comments`
--

CREATE TABLE `wp_comments` (
  `comment_ID` bigint(20) UNSIGNED NOT NULL,
  `comment_post_ID` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `comment_author` tinytext COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment_author_email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment_author_url` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment_author_IP` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `comment_date_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `comment_content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment_karma` int(11) NOT NULL DEFAULT '0',
  `comment_approved` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1',
  `comment_agent` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment_parent` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `user_id` bigint(20) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wp_comments`
--

INSERT INTO `wp_comments` (`comment_ID`, `comment_post_ID`, `comment_author`, `comment_author_email`, `comment_author_url`, `comment_author_IP`, `comment_date`, `comment_date_gmt`, `comment_content`, `comment_karma`, `comment_approved`, `comment_agent`, `comment_type`, `comment_parent`, `user_id`) VALUES
(1, 1, 'A WordPress Commenter', 'wapuu@wordpress.example', 'https://wordpress.org/', '', '2018-02-07 11:58:18', '2018-02-07 11:58:18', 'Hi, this is a comment.\nTo get started with moderating, editing, and deleting comments, please visit the Comments screen in the dashboard.\nCommenter avatars come from <a href=\"https://gravatar.com\">Gravatar</a>.', 0, 'post-trashed', '', '', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `wp_links`
--

CREATE TABLE `wp_links` (
  `link_id` bigint(20) UNSIGNED NOT NULL,
  `link_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `link_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `link_image` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `link_target` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `link_description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `link_visible` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Y',
  `link_owner` bigint(20) UNSIGNED NOT NULL DEFAULT '1',
  `link_rating` int(11) NOT NULL DEFAULT '0',
  `link_updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `link_rel` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `link_notes` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `link_rss` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wp_ngg_album`
--

CREATE TABLE `wp_ngg_album` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `previewpic` bigint(20) NOT NULL DEFAULT '0',
  `albumdesc` mediumtext COLLATE utf8mb4_unicode_ci,
  `sortorder` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `pageid` bigint(20) NOT NULL DEFAULT '0',
  `extras_post_id` bigint(20) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wp_ngg_gallery`
--

CREATE TABLE `wp_ngg_gallery` (
  `gid` bigint(20) NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `path` mediumtext COLLATE utf8mb4_unicode_ci,
  `title` mediumtext COLLATE utf8mb4_unicode_ci,
  `galdesc` mediumtext COLLATE utf8mb4_unicode_ci,
  `pageid` bigint(20) NOT NULL DEFAULT '0',
  `previewpic` bigint(20) NOT NULL DEFAULT '0',
  `author` bigint(20) NOT NULL DEFAULT '0',
  `extras_post_id` bigint(20) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wp_ngg_pictures`
--

CREATE TABLE `wp_ngg_pictures` (
  `pid` bigint(20) NOT NULL,
  `image_slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_id` bigint(20) NOT NULL DEFAULT '0',
  `galleryid` bigint(20) NOT NULL DEFAULT '0',
  `filename` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` mediumtext COLLATE utf8mb4_unicode_ci,
  `alttext` mediumtext COLLATE utf8mb4_unicode_ci,
  `imagedate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `exclude` tinyint(4) DEFAULT '0',
  `sortorder` bigint(20) NOT NULL DEFAULT '0',
  `meta_data` longtext COLLATE utf8mb4_unicode_ci,
  `extras_post_id` bigint(20) NOT NULL DEFAULT '0',
  `updated_at` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wp_options`
--

CREATE TABLE `wp_options` (
  `option_id` bigint(20) UNSIGNED NOT NULL,
  `option_name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `option_value` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `autoload` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yes'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wp_options`
--

INSERT INTO `wp_options` (`option_id`, `option_name`, `option_value`, `autoload`) VALUES
(1, 'siteurl', 'http://104.155.81.48', 'yes'),
(2, 'home', 'http://104.155.81.48', 'yes'),
(3, 'blogname', 'Photography Guy', 'yes'),
(4, 'blogdescription', 'Just another photography blog', 'yes'),
(5, 'users_can_register', '0', 'yes'),
(6, 'admin_email', 'guy210690@gmail.com', 'yes'),
(7, 'start_of_week', '0', 'yes'),
(8, 'use_balanceTags', '0', 'yes'),
(9, 'use_smilies', '1', 'yes'),
(10, 'require_name_email', '1', 'yes'),
(11, 'comments_notify', '1', 'yes'),
(12, 'posts_per_rss', '10', 'yes'),
(13, 'rss_use_excerpt', '0', 'yes'),
(14, 'mailserver_url', 'mail.example.com', 'yes'),
(15, 'mailserver_login', 'login@example.com', 'yes'),
(16, 'mailserver_pass', 'password', 'yes'),
(17, 'mailserver_port', '110', 'yes'),
(18, 'default_category', '1', 'yes'),
(19, 'default_comment_status', 'open', 'yes'),
(20, 'default_ping_status', 'open', 'yes'),
(21, 'default_pingback_flag', '1', 'yes'),
(22, 'posts_per_page', '10', 'yes'),
(23, 'date_format', 'F j, Y', 'yes'),
(24, 'time_format', 'g:i a', 'yes'),
(25, 'links_updated_date_format', 'F j, Y g:i a', 'yes'),
(26, 'comment_moderation', '0', 'yes'),
(27, 'moderation_notify', '1', 'yes'),
(28, 'permalink_structure', '/index.php/%year%/%monthnum%/%day%/%postname%/', 'yes'),
(29, 'rewrite_rules', 'a:90:{s:11:\"^wp-json/?$\";s:22:\"index.php?rest_route=/\";s:14:\"^wp-json/(.*)?\";s:33:\"index.php?rest_route=/$matches[1]\";s:21:\"^index.php/wp-json/?$\";s:22:\"index.php?rest_route=/\";s:24:\"^index.php/wp-json/(.*)?\";s:33:\"index.php?rest_route=/$matches[1]\";s:57:\"index.php/category/(.+?)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:52:\"index.php?category_name=$matches[1]&feed=$matches[2]\";s:52:\"index.php/category/(.+?)/(feed|rdf|rss|rss2|atom)/?$\";s:52:\"index.php?category_name=$matches[1]&feed=$matches[2]\";s:33:\"index.php/category/(.+?)/embed/?$\";s:46:\"index.php?category_name=$matches[1]&embed=true\";s:45:\"index.php/category/(.+?)/page/?([0-9]{1,})/?$\";s:53:\"index.php?category_name=$matches[1]&paged=$matches[2]\";s:27:\"index.php/category/(.+?)/?$\";s:35:\"index.php?category_name=$matches[1]\";s:54:\"index.php/tag/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?tag=$matches[1]&feed=$matches[2]\";s:49:\"index.php/tag/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?tag=$matches[1]&feed=$matches[2]\";s:30:\"index.php/tag/([^/]+)/embed/?$\";s:36:\"index.php?tag=$matches[1]&embed=true\";s:42:\"index.php/tag/([^/]+)/page/?([0-9]{1,})/?$\";s:43:\"index.php?tag=$matches[1]&paged=$matches[2]\";s:24:\"index.php/tag/([^/]+)/?$\";s:25:\"index.php?tag=$matches[1]\";s:55:\"index.php/type/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?post_format=$matches[1]&feed=$matches[2]\";s:50:\"index.php/type/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?post_format=$matches[1]&feed=$matches[2]\";s:31:\"index.php/type/([^/]+)/embed/?$\";s:44:\"index.php?post_format=$matches[1]&embed=true\";s:43:\"index.php/type/([^/]+)/page/?([0-9]{1,})/?$\";s:51:\"index.php?post_format=$matches[1]&paged=$matches[2]\";s:25:\"index.php/type/([^/]+)/?$\";s:33:\"index.php?post_format=$matches[1]\";s:12:\"robots\\.txt$\";s:18:\"index.php?robots=1\";s:48:\".*wp-(atom|rdf|rss|rss2|feed|commentsrss2)\\.php$\";s:18:\"index.php?feed=old\";s:20:\".*wp-app\\.php(/.*)?$\";s:19:\"index.php?error=403\";s:18:\".*wp-register.php$\";s:23:\"index.php?register=true\";s:42:\"index.php/feed/(feed|rdf|rss|rss2|atom)/?$\";s:27:\"index.php?&feed=$matches[1]\";s:37:\"index.php/(feed|rdf|rss|rss2|atom)/?$\";s:27:\"index.php?&feed=$matches[1]\";s:18:\"index.php/embed/?$\";s:21:\"index.php?&embed=true\";s:30:\"index.php/page/?([0-9]{1,})/?$\";s:28:\"index.php?&paged=$matches[1]\";s:51:\"index.php/comments/feed/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?&feed=$matches[1]&withcomments=1\";s:46:\"index.php/comments/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?&feed=$matches[1]&withcomments=1\";s:27:\"index.php/comments/embed/?$\";s:21:\"index.php?&embed=true\";s:54:\"index.php/search/(.+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:40:\"index.php?s=$matches[1]&feed=$matches[2]\";s:49:\"index.php/search/(.+)/(feed|rdf|rss|rss2|atom)/?$\";s:40:\"index.php?s=$matches[1]&feed=$matches[2]\";s:30:\"index.php/search/(.+)/embed/?$\";s:34:\"index.php?s=$matches[1]&embed=true\";s:42:\"index.php/search/(.+)/page/?([0-9]{1,})/?$\";s:41:\"index.php?s=$matches[1]&paged=$matches[2]\";s:24:\"index.php/search/(.+)/?$\";s:23:\"index.php?s=$matches[1]\";s:57:\"index.php/author/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?author_name=$matches[1]&feed=$matches[2]\";s:52:\"index.php/author/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?author_name=$matches[1]&feed=$matches[2]\";s:33:\"index.php/author/([^/]+)/embed/?$\";s:44:\"index.php?author_name=$matches[1]&embed=true\";s:45:\"index.php/author/([^/]+)/page/?([0-9]{1,})/?$\";s:51:\"index.php?author_name=$matches[1]&paged=$matches[2]\";s:27:\"index.php/author/([^/]+)/?$\";s:33:\"index.php?author_name=$matches[1]\";s:79:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/feed/(feed|rdf|rss|rss2|atom)/?$\";s:80:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&feed=$matches[4]\";s:74:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/(feed|rdf|rss|rss2|atom)/?$\";s:80:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&feed=$matches[4]\";s:55:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/embed/?$\";s:74:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&embed=true\";s:67:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/page/?([0-9]{1,})/?$\";s:81:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&paged=$matches[4]\";s:49:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/?$\";s:63:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]\";s:66:\"index.php/([0-9]{4})/([0-9]{1,2})/feed/(feed|rdf|rss|rss2|atom)/?$\";s:64:\"index.php?year=$matches[1]&monthnum=$matches[2]&feed=$matches[3]\";s:61:\"index.php/([0-9]{4})/([0-9]{1,2})/(feed|rdf|rss|rss2|atom)/?$\";s:64:\"index.php?year=$matches[1]&monthnum=$matches[2]&feed=$matches[3]\";s:42:\"index.php/([0-9]{4})/([0-9]{1,2})/embed/?$\";s:58:\"index.php?year=$matches[1]&monthnum=$matches[2]&embed=true\";s:54:\"index.php/([0-9]{4})/([0-9]{1,2})/page/?([0-9]{1,})/?$\";s:65:\"index.php?year=$matches[1]&monthnum=$matches[2]&paged=$matches[3]\";s:36:\"index.php/([0-9]{4})/([0-9]{1,2})/?$\";s:47:\"index.php?year=$matches[1]&monthnum=$matches[2]\";s:53:\"index.php/([0-9]{4})/feed/(feed|rdf|rss|rss2|atom)/?$\";s:43:\"index.php?year=$matches[1]&feed=$matches[2]\";s:48:\"index.php/([0-9]{4})/(feed|rdf|rss|rss2|atom)/?$\";s:43:\"index.php?year=$matches[1]&feed=$matches[2]\";s:29:\"index.php/([0-9]{4})/embed/?$\";s:37:\"index.php?year=$matches[1]&embed=true\";s:41:\"index.php/([0-9]{4})/page/?([0-9]{1,})/?$\";s:44:\"index.php?year=$matches[1]&paged=$matches[2]\";s:23:\"index.php/([0-9]{4})/?$\";s:26:\"index.php?year=$matches[1]\";s:68:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:78:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:98:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:93:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:93:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:74:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:63:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/embed/?$\";s:91:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&embed=true\";s:67:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/trackback/?$\";s:85:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&tb=1\";s:87:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:97:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&feed=$matches[5]\";s:82:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:97:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&feed=$matches[5]\";s:75:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/page/?([0-9]{1,})/?$\";s:98:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&paged=$matches[5]\";s:82:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/comment-page-([0-9]{1,})/?$\";s:98:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&cpage=$matches[5]\";s:71:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)(?:/([0-9]+))?/?$\";s:97:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&page=$matches[5]\";s:57:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:67:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:87:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:82:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:82:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:63:\"index.php/[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:74:\"index.php/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/comment-page-([0-9]{1,})/?$\";s:81:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&cpage=$matches[4]\";s:61:\"index.php/([0-9]{4})/([0-9]{1,2})/comment-page-([0-9]{1,})/?$\";s:65:\"index.php?year=$matches[1]&monthnum=$matches[2]&cpage=$matches[3]\";s:48:\"index.php/([0-9]{4})/comment-page-([0-9]{1,})/?$\";s:44:\"index.php?year=$matches[1]&cpage=$matches[2]\";s:37:\"index.php/.?.+?/attachment/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:47:\"index.php/.?.+?/attachment/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:67:\"index.php/.?.+?/attachment/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:62:\"index.php/.?.+?/attachment/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:62:\"index.php/.?.+?/attachment/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:43:\"index.php/.?.+?/attachment/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:26:\"index.php/(.?.+?)/embed/?$\";s:41:\"index.php?pagename=$matches[1]&embed=true\";s:30:\"index.php/(.?.+?)/trackback/?$\";s:35:\"index.php?pagename=$matches[1]&tb=1\";s:50:\"index.php/(.?.+?)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:47:\"index.php?pagename=$matches[1]&feed=$matches[2]\";s:45:\"index.php/(.?.+?)/(feed|rdf|rss|rss2|atom)/?$\";s:47:\"index.php?pagename=$matches[1]&feed=$matches[2]\";s:38:\"index.php/(.?.+?)/page/?([0-9]{1,})/?$\";s:48:\"index.php?pagename=$matches[1]&paged=$matches[2]\";s:45:\"index.php/(.?.+?)/comment-page-([0-9]{1,})/?$\";s:48:\"index.php?pagename=$matches[1]&cpage=$matches[2]\";s:34:\"index.php/(.?.+?)(?:/([0-9]+))?/?$\";s:47:\"index.php?pagename=$matches[1]&page=$matches[2]\";}', 'yes'),
(30, 'hack_file', '0', 'yes'),
(31, 'blog_charset', 'UTF-8', 'yes'),
(32, 'moderation_keys', '', 'no'),
(33, 'active_plugins', 'a:3:{i:0;s:29:\"meow-gallery/meow-gallery.php\";i:1;s:31:\"meow-lightbox/meow-lightbox.php\";i:3;s:23:\"wp-smushit/wp-smush.php\";}', 'yes'),
(34, 'category_base', '', 'yes'),
(35, 'ping_sites', 'http://rpc.pingomatic.com/', 'yes'),
(36, 'comment_max_links', '2', 'yes'),
(37, 'gmt_offset', '0', 'yes'),
(38, 'default_email_category', '1', 'yes'),
(39, 'recently_edited', 'a:2:{i:0;s:50:\"/var/www/html/wp-content/themes/lucienne/style.css\";i:2;s:0:\"\";}', 'no'),
(40, 'template', 'lucienne', 'yes'),
(41, 'stylesheet', 'lucienne', 'yes'),
(42, 'comment_whitelist', '1', 'yes'),
(43, 'blacklist_keys', '', 'no'),
(44, 'comment_registration', '0', 'yes'),
(45, 'html_type', 'text/html', 'yes'),
(46, 'use_trackback', '0', 'yes'),
(47, 'default_role', 'subscriber', 'yes'),
(48, 'db_version', '38590', 'yes'),
(49, 'uploads_use_yearmonth_folders', '1', 'yes'),
(50, 'upload_path', '', 'yes'),
(51, 'blog_public', '1', 'yes'),
(52, 'default_link_category', '2', 'yes'),
(53, 'show_on_front', 'posts', 'yes'),
(54, 'tag_base', '', 'yes'),
(55, 'show_avatars', '1', 'yes'),
(56, 'avatar_rating', 'G', 'yes'),
(57, 'upload_url_path', '', 'yes'),
(58, 'thumbnail_size_w', '150', 'yes'),
(59, 'thumbnail_size_h', '150', 'yes'),
(60, 'thumbnail_crop', '1', 'yes'),
(61, 'medium_size_w', '300', 'yes'),
(62, 'medium_size_h', '300', 'yes'),
(63, 'avatar_default', 'mystery', 'yes'),
(64, 'large_size_w', '1024', 'yes'),
(65, 'large_size_h', '1024', 'yes'),
(66, 'image_default_link_type', 'none', 'yes'),
(67, 'image_default_size', '', 'yes'),
(68, 'image_default_align', '', 'yes'),
(69, 'close_comments_for_old_posts', '0', 'yes'),
(70, 'close_comments_days_old', '14', 'yes'),
(71, 'thread_comments', '1', 'yes'),
(72, 'thread_comments_depth', '5', 'yes'),
(73, 'page_comments', '0', 'yes'),
(74, 'comments_per_page', '50', 'yes'),
(75, 'default_comments_page', 'newest', 'yes'),
(76, 'comment_order', 'asc', 'yes'),
(77, 'sticky_posts', 'a:0:{}', 'yes'),
(78, 'widget_categories', 'a:2:{i:2;a:4:{s:5:\"title\";s:0:\"\";s:5:\"count\";i:0;s:12:\"hierarchical\";i:0;s:8:\"dropdown\";i:0;}s:12:\"_multiwidget\";i:1;}', 'yes'),
(79, 'widget_text', 'a:2:{i:1;a:0:{}s:12:\"_multiwidget\";i:1;}', 'yes'),
(80, 'widget_rss', 'a:2:{i:1;a:0:{}s:12:\"_multiwidget\";i:1;}', 'yes'),
(81, 'uninstall_plugins', 'a:1:{s:29:\"nextgen-gallery/nggallery.php\";a:2:{i:0;s:8:\"Freemius\";i:1;s:22:\"_uninstall_plugin_hook\";}}', 'no'),
(82, 'timezone_string', '', 'yes'),
(83, 'page_for_posts', '0', 'yes'),
(84, 'page_on_front', '0', 'yes'),
(85, 'default_post_format', '0', 'yes'),
(86, 'link_manager_enabled', '0', 'yes'),
(87, 'finished_splitting_shared_terms', '1', 'yes'),
(88, 'site_icon', '0', 'yes'),
(89, 'medium_large_size_w', '768', 'yes'),
(90, 'medium_large_size_h', '0', 'yes'),
(91, 'initial_db_version', '38590', 'yes'),
(92, 'wp_user_roles', 'a:5:{s:13:\"administrator\";a:2:{s:4:\"name\";s:13:\"Administrator\";s:12:\"capabilities\";a:63:{s:13:\"switch_themes\";b:1;s:11:\"edit_themes\";b:1;s:16:\"activate_plugins\";b:1;s:12:\"edit_plugins\";b:1;s:10:\"edit_users\";b:1;s:10:\"edit_files\";b:1;s:14:\"manage_options\";b:1;s:17:\"moderate_comments\";b:1;s:17:\"manage_categories\";b:1;s:12:\"manage_links\";b:1;s:12:\"upload_files\";b:1;s:6:\"import\";b:1;s:15:\"unfiltered_html\";b:1;s:10:\"edit_posts\";b:1;s:17:\"edit_others_posts\";b:1;s:20:\"edit_published_posts\";b:1;s:13:\"publish_posts\";b:1;s:10:\"edit_pages\";b:1;s:4:\"read\";b:1;s:8:\"level_10\";b:1;s:7:\"level_9\";b:1;s:7:\"level_8\";b:1;s:7:\"level_7\";b:1;s:7:\"level_6\";b:1;s:7:\"level_5\";b:1;s:7:\"level_4\";b:1;s:7:\"level_3\";b:1;s:7:\"level_2\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:17:\"edit_others_pages\";b:1;s:20:\"edit_published_pages\";b:1;s:13:\"publish_pages\";b:1;s:12:\"delete_pages\";b:1;s:19:\"delete_others_pages\";b:1;s:22:\"delete_published_pages\";b:1;s:12:\"delete_posts\";b:1;s:19:\"delete_others_posts\";b:1;s:22:\"delete_published_posts\";b:1;s:20:\"delete_private_posts\";b:1;s:18:\"edit_private_posts\";b:1;s:18:\"read_private_posts\";b:1;s:20:\"delete_private_pages\";b:1;s:18:\"edit_private_pages\";b:1;s:18:\"read_private_pages\";b:1;s:12:\"delete_users\";b:1;s:12:\"create_users\";b:1;s:17:\"unfiltered_upload\";b:1;s:14:\"edit_dashboard\";b:1;s:14:\"update_plugins\";b:1;s:14:\"delete_plugins\";b:1;s:15:\"install_plugins\";b:1;s:13:\"update_themes\";b:1;s:14:\"install_themes\";b:1;s:11:\"update_core\";b:1;s:10:\"list_users\";b:1;s:12:\"remove_users\";b:1;s:13:\"promote_users\";b:1;s:18:\"edit_theme_options\";b:1;s:13:\"delete_themes\";b:1;s:6:\"export\";b:1;s:19:\"NextGEN Manage tags\";b:1;s:29:\"NextGEN Manage others gallery\";b:1;}}s:6:\"editor\";a:2:{s:4:\"name\";s:6:\"Editor\";s:12:\"capabilities\";a:34:{s:17:\"moderate_comments\";b:1;s:17:\"manage_categories\";b:1;s:12:\"manage_links\";b:1;s:12:\"upload_files\";b:1;s:15:\"unfiltered_html\";b:1;s:10:\"edit_posts\";b:1;s:17:\"edit_others_posts\";b:1;s:20:\"edit_published_posts\";b:1;s:13:\"publish_posts\";b:1;s:10:\"edit_pages\";b:1;s:4:\"read\";b:1;s:7:\"level_7\";b:1;s:7:\"level_6\";b:1;s:7:\"level_5\";b:1;s:7:\"level_4\";b:1;s:7:\"level_3\";b:1;s:7:\"level_2\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:17:\"edit_others_pages\";b:1;s:20:\"edit_published_pages\";b:1;s:13:\"publish_pages\";b:1;s:12:\"delete_pages\";b:1;s:19:\"delete_others_pages\";b:1;s:22:\"delete_published_pages\";b:1;s:12:\"delete_posts\";b:1;s:19:\"delete_others_posts\";b:1;s:22:\"delete_published_posts\";b:1;s:20:\"delete_private_posts\";b:1;s:18:\"edit_private_posts\";b:1;s:18:\"read_private_posts\";b:1;s:20:\"delete_private_pages\";b:1;s:18:\"edit_private_pages\";b:1;s:18:\"read_private_pages\";b:1;}}s:6:\"author\";a:2:{s:4:\"name\";s:6:\"Author\";s:12:\"capabilities\";a:10:{s:12:\"upload_files\";b:1;s:10:\"edit_posts\";b:1;s:20:\"edit_published_posts\";b:1;s:13:\"publish_posts\";b:1;s:4:\"read\";b:1;s:7:\"level_2\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:12:\"delete_posts\";b:1;s:22:\"delete_published_posts\";b:1;}}s:11:\"contributor\";a:2:{s:4:\"name\";s:11:\"Contributor\";s:12:\"capabilities\";a:5:{s:10:\"edit_posts\";b:1;s:4:\"read\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:12:\"delete_posts\";b:1;}}s:10:\"subscriber\";a:2:{s:4:\"name\";s:10:\"Subscriber\";s:12:\"capabilities\";a:2:{s:4:\"read\";b:1;s:7:\"level_0\";b:1;}}}', 'yes'),
(93, 'fresh_site', '0', 'yes'),
(94, 'widget_search', 'a:2:{i:2;a:1:{s:5:\"title\";s:0:\"\";}s:12:\"_multiwidget\";i:1;}', 'yes'),
(95, 'widget_recent-posts', 'a:2:{i:2;a:2:{s:5:\"title\";s:0:\"\";s:6:\"number\";i:5;}s:12:\"_multiwidget\";i:1;}', 'yes'),
(96, 'widget_recent-comments', 'a:2:{i:2;a:2:{s:5:\"title\";s:0:\"\";s:6:\"number\";i:5;}s:12:\"_multiwidget\";i:1;}', 'yes'),
(97, 'widget_archives', 'a:2:{i:2;a:3:{s:5:\"title\";s:0:\"\";s:5:\"count\";i:0;s:8:\"dropdown\";i:0;}s:12:\"_multiwidget\";i:1;}', 'yes'),
(98, 'widget_meta', 'a:2:{i:2;a:1:{s:5:\"title\";s:0:\"\";}s:12:\"_multiwidget\";i:1;}', 'yes'),
(99, 'sidebars_widgets', 'a:8:{s:19:\"wp_inactive_widgets\";a:3:{i:0;s:10:\"archives-2\";i:1;s:6:\"meta-2\";i:2;s:17:\"recent-comments-2\";}s:9:\"sidebar-1\";a:3:{i:0;s:8:\"search-2\";i:1;s:14:\"recent-posts-2\";i:2;s:12:\"categories-2\";}s:8:\"home-top\";a:0:{}s:11:\"home-bottom\";a:0:{}s:8:\"footer-1\";a:0:{}s:8:\"footer-2\";a:0:{}s:8:\"footer-3\";a:0:{}s:13:\"array_version\";i:3;}', 'yes'),
(100, 'widget_pages', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(101, 'widget_calendar', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(102, 'widget_media_audio', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(103, 'widget_media_image', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(104, 'widget_media_gallery', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(105, 'widget_media_video', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(106, 'widget_tag_cloud', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(107, 'widget_nav_menu', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(108, 'widget_custom_html', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(109, 'cron', 'a:4:{i:1518470405;a:1:{s:30:\"wp_scheduled_auto_draft_delete\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}}i:1518479898;a:3:{s:16:\"wp_version_check\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:10:\"twicedaily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:43200;}}s:17:\"wp_update_plugins\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:10:\"twicedaily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:43200;}}s:16:\"wp_update_themes\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:10:\"twicedaily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:43200;}}}i:1518523109;a:2:{s:19:\"wp_scheduled_delete\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}s:25:\"delete_expired_transients\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}}s:7:\"version\";i:2;}', 'yes'),
(110, 'theme_mods_twentyseventeen', 'a:3:{s:18:\"custom_css_post_id\";i:-1;s:16:\"sidebars_widgets\";a:2:{s:4:\"time\";i:1518039195;s:4:\"data\";a:4:{s:19:\"wp_inactive_widgets\";a:0:{}s:9:\"sidebar-1\";a:6:{i:0;s:8:\"search-2\";i:1;s:14:\"recent-posts-2\";i:2;s:17:\"recent-comments-2\";i:3;s:10:\"archives-2\";i:4;s:12:\"categories-2\";i:5;s:6:\"meta-2\";}s:9:\"sidebar-2\";a:0:{}s:9:\"sidebar-3\";a:0:{}}}s:18:\"nav_menu_locations\";a:0:{}}', 'yes'),
(114, '_site_transient_update_core', 'O:8:\"stdClass\":4:{s:7:\"updates\";a:1:{i:0;O:8:\"stdClass\":10:{s:8:\"response\";s:6:\"latest\";s:8:\"download\";s:59:\"https://downloads.wordpress.org/release/wordpress-4.9.4.zip\";s:6:\"locale\";s:5:\"en_US\";s:8:\"packages\";O:8:\"stdClass\":5:{s:4:\"full\";s:59:\"https://downloads.wordpress.org/release/wordpress-4.9.4.zip\";s:10:\"no_content\";s:70:\"https://downloads.wordpress.org/release/wordpress-4.9.4-no-content.zip\";s:11:\"new_bundled\";s:71:\"https://downloads.wordpress.org/release/wordpress-4.9.4-new-bundled.zip\";s:7:\"partial\";b:0;s:8:\"rollback\";b:0;}s:7:\"current\";s:5:\"4.9.4\";s:7:\"version\";s:5:\"4.9.4\";s:11:\"php_version\";s:5:\"5.2.4\";s:13:\"mysql_version\";s:3:\"5.0\";s:11:\"new_bundled\";s:3:\"4.7\";s:15:\"partial_version\";s:0:\"\";}}s:12:\"last_checked\";i:1518437639;s:15:\"version_checked\";s:5:\"4.9.4\";s:12:\"translations\";a:0:{}}', 'no'),
(120, '_site_transient_timeout_browser_b876c8fd7fc402e60530b64622320f7a', '1518609509', 'no'),
(121, '_site_transient_browser_b876c8fd7fc402e60530b64622320f7a', 'a:10:{s:4:\"name\";s:6:\"Chrome\";s:7:\"version\";s:13:\"63.0.3239.132\";s:8:\"platform\";s:7:\"Windows\";s:10:\"update_url\";s:29:\"https://www.google.com/chrome\";s:7:\"img_src\";s:43:\"http://s.w.org/images/browsers/chrome.png?1\";s:11:\"img_src_ssl\";s:44:\"https://s.w.org/images/browsers/chrome.png?1\";s:15:\"current_version\";s:2:\"18\";s:7:\"upgrade\";b:0;s:8:\"insecure\";b:0;s:6:\"mobile\";b:0;}', 'no'),
(123, 'can_compress_scripts', '0', 'no'),
(138, 'current_theme', 'Lucienne', 'yes'),
(139, 'theme_mods_the-dylan', 'a:4:{i:0;b:0;s:18:\"nav_menu_locations\";a:0:{}s:18:\"custom_css_post_id\";i:-1;s:16:\"sidebars_widgets\";a:2:{s:4:\"time\";i:1518036583;s:4:\"data\";a:5:{s:19:\"wp_inactive_widgets\";a:0:{}s:9:\"sidebar-1\";a:6:{i:0;s:8:\"search-2\";i:1;s:14:\"recent-posts-2\";i:2;s:17:\"recent-comments-2\";i:3;s:10:\"archives-2\";i:4;s:12:\"categories-2\";i:5;s:6:\"meta-2\";}s:17:\"footer-one-widget\";a:0:{}s:17:\"footer-two-widget\";a:0:{}s:19:\"footer-three-widget\";a:0:{}}}}', 'yes'),
(140, 'theme_switched', '', 'yes'),
(141, 'widget_the_dylan_recent_posts', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(147, '_site_transient_timeout_browser_66e1cec84d8202a4e5a46a1881959ec1', '1518641304', 'no'),
(148, '_site_transient_browser_66e1cec84d8202a4e5a46a1881959ec1', 'a:10:{s:4:\"name\";s:6:\"Chrome\";s:7:\"version\";s:13:\"63.0.3239.132\";s:8:\"platform\";s:7:\"Windows\";s:10:\"update_url\";s:29:\"https://www.google.com/chrome\";s:7:\"img_src\";s:43:\"http://s.w.org/images/browsers/chrome.png?1\";s:11:\"img_src_ssl\";s:44:\"https://s.w.org/images/browsers/chrome.png?1\";s:15:\"current_version\";s:2:\"18\";s:7:\"upgrade\";b:0;s:8:\"insecure\";b:0;s:6:\"mobile\";b:0;}', 'no'),
(156, 'theme_mods_lucienne', 'a:6:{i:0;b:0;s:18:\"nav_menu_locations\";a:0:{}s:18:\"custom_css_post_id\";i:-1;s:12:\"header_image\";s:13:\"remove-header\";s:16:\"sidebars_widgets\";a:2:{s:4:\"time\";i:1518086769;s:4:\"data\";a:7:{s:19:\"wp_inactive_widgets\";a:0:{}s:9:\"sidebar-1\";a:3:{i:0;s:8:\"search-2\";i:1;s:14:\"recent-posts-2\";i:2;s:12:\"categories-2\";}s:8:\"home-top\";a:0:{}s:11:\"home-bottom\";a:0:{}s:8:\"footer-1\";a:0:{}s:8:\"footer-2\";a:0:{}s:8:\"footer-3\";a:0:{}}}s:16:\"carousel_setting\";s:1:\"2\";}', 'yes'),
(166, 'category_children', 'a:0:{}', 'yes'),
(177, 'recently_activated', 'a:2:{s:29:\"nextgen-gallery/nggallery.php\";i:1518076432;s:27:\"thesography/exifography.php\";i:1518040256;}', 'yes'),
(182, 'wdev-frash', 'a:3:{s:7:\"plugins\";a:1:{s:23:\"wp-smushit/wp-smush.php\";i:1518039365;}s:5:\"queue\";a:2:{s:32:\"7de3619981caadc55f30a002bfb299f6\";a:4:{s:6:\"plugin\";s:23:\"wp-smushit/wp-smush.php\";s:4:\"type\";s:5:\"email\";s:7:\"show_at\";i:1518039365;s:6:\"sticky\";b:1;}s:32:\"fc50097023d0d34c5a66f6cddcf77694\";a:3:{s:6:\"plugin\";s:23:\"wp-smushit/wp-smush.php\";s:4:\"type\";s:4:\"rate\";s:7:\"show_at\";i:1518644165;}}s:4:\"done\";a:0:{}}', 'no'),
(183, 'wp-smush-install-type', 'existing', 'no'),
(184, 'wp-smush-version', '2.7.6', 'no'),
(185, 'wp-smush-skip-redirect', '1', 'no'),
(186, 'smush_global_stats', 'a:9:{s:11:\"size_before\";i:0;s:10:\"size_after\";i:0;s:7:\"percent\";d:0;s:5:\"human\";s:5:\"0.0 B\";s:5:\"bytes\";i:0;s:12:\"total_images\";i:0;s:14:\"resize_savings\";i:0;s:12:\"resize_count\";i:0;s:18:\"conversion_savings\";i:0;}', 'no'),
(191, 'dir_smush_stats', 'a:2:{s:9:\"dir_smush\";a:2:{s:5:\"total\";s:1:\"0\";s:9:\"optimised\";i:0;}s:14:\"combined_stats\";a:0:{}}', 'no'),
(192, 'wp-smush-resize_sizes', 'a:2:{s:5:\"width\";i:2048;s:6:\"height\";i:2048;}', 'no'),
(193, 'wp-smush-last_settings', 'a:3:{s:4:\"auto\";i:1;s:9:\"keep_exif\";i:0;s:6:\"resize\";i:1;}', 'no'),
(194, 'skip-smush-setup', '1', 'no'),
(202, 'exifography_options', 'a:13:{s:11:\"exif_fields\";a:5:{i:0;s:8:\"aperture\";i:1;s:6:\"camera\";i:2;s:12:\"focal_length\";i:3;s:3:\"iso\";i:4;s:13:\"shutter_speed\";}s:11:\"auto_insert\";i:1;s:12:\"before_block\";s:29:\"<ul id=\\\"%s\\\" class=\\\"exif\\\">\";s:11:\"before_item\";s:17:\"<li class=\\\"%s\\\">\";s:10:\"after_item\";s:5:\"</li>\";s:11:\"after_block\";s:5:\"</ul>\";s:3:\"sep\";s:2:\": \";s:9:\"timestamp\";s:6:\"j F, Y\";s:8:\"geo_zoom\";s:1:\"2\";s:9:\"geo_width\";s:3:\"100\";s:10:\"geo_height\";s:3:\"100\";s:7:\"geo_key\";s:0:\"\";s:5:\"order\";a:14:{i:0;s:8:\"aperture\";i:1;s:6:\"credit\";i:2;s:6:\"camera\";i:3;s:7:\"caption\";i:4;s:17:\"created_timestamp\";i:5;s:9:\"copyright\";i:6;s:13:\"exposure_bias\";i:7;s:5:\"flash\";i:8;s:12:\"focal_length\";i:9;s:3:\"iso\";i:10;s:8:\"keywords\";i:11;s:8:\"location\";i:12;s:13:\"shutter_speed\";i:13;s:5:\"title\";}}', 'yes'),
(215, 'ngg_run_freemius', '1', 'yes'),
(216, 'fs_active_plugins', 'O:8:\"stdClass\":0:{}', 'yes'),
(217, 'fs_debug_mode', '', 'yes'),
(218, 'fs_accounts', 'a:11:{s:11:\"plugin_data\";a:1:{s:15:\"nextgen-gallery\";a:18:{s:16:\"plugin_main_file\";O:8:\"stdClass\":1:{s:9:\"prev_path\";s:62:\"/var/www/html/wp-content/plugins/nextgen-gallery/nggallery.php\";}s:17:\"install_timestamp\";i:1518040083;s:16:\"sdk_last_version\";N;s:11:\"sdk_version\";s:7:\"1.2.1.5\";s:16:\"sdk_upgrade_mode\";b:1;s:18:\"sdk_downgrade_mode\";b:0;s:19:\"plugin_last_version\";N;s:14:\"plugin_version\";s:6:\"2.2.33\";s:19:\"plugin_upgrade_mode\";b:1;s:21:\"plugin_downgrade_mode\";b:0;s:21:\"is_plugin_new_install\";b:1;s:17:\"connectivity_test\";a:6:{s:12:\"is_connected\";b:1;s:4:\"host\";s:13:\"104.155.81.48\";s:9:\"server_ip\";s:13:\"5.102.232.120\";s:9:\"is_active\";b:1;s:9:\"timestamp\";i:1518040083;s:7:\"version\";s:6:\"2.2.33\";}s:17:\"was_plugin_loaded\";b:1;s:15:\"prev_is_premium\";b:0;s:14:\"has_trial_plan\";b:1;s:22:\"install_sync_timestamp\";i:1518076431;s:20:\"activation_timestamp\";i:1518040098;s:16:\"uninstall_reason\";O:8:\"stdClass\":3:{s:2:\"id\";s:1:\"2\";s:4:\"info\";s:0:\"\";s:12:\"is_anonymous\";b:0;}}}s:13:\"file_slug_map\";a:1:{s:29:\"nextgen-gallery/nggallery.php\";s:15:\"nextgen-gallery\";}s:7:\"plugins\";a:1:{s:15:\"nextgen-gallery\";O:9:\"FS_Plugin\":16:{s:16:\"parent_plugin_id\";N;s:5:\"title\";s:15:\"NextGEN Gallery\";s:4:\"slug\";s:15:\"nextgen-gallery\";s:4:\"type\";N;s:4:\"file\";s:29:\"nextgen-gallery/nggallery.php\";s:7:\"version\";s:6:\"2.2.33\";s:11:\"auto_update\";N;s:4:\"info\";N;s:10:\"is_premium\";b:0;s:7:\"is_live\";b:1;s:10:\"public_key\";s:32:\"pk_009356711cd548837f074e1ef60a4\";s:10:\"secret_key\";N;s:2:\"id\";s:3:\"266\";s:7:\"updated\";N;s:7:\"created\";N;s:22:\"\0FS_Entity\0_is_updated\";b:0;}}s:9:\"unique_id\";s:32:\"c3ec631c85c925c69fc2dae6cbff7882\";s:5:\"plans\";a:1:{s:15:\"nextgen-gallery\";a:1:{i:0;O:14:\"FS_Plugin_Plan\":21:{s:9:\"plugin_id\";s:4:\"MjY2\";s:4:\"name\";s:8:\"ZnJlZQ==\";s:5:\"title\";s:8:\"RnJlZQ==\";s:11:\"description\";N;s:17:\"is_free_localhost\";s:4:\"MQ==\";s:17:\"is_block_features\";s:4:\"MQ==\";s:12:\"license_type\";s:4:\"MA==\";s:16:\"is_https_support\";s:0:\"\";s:12:\"trial_period\";N;s:23:\"is_require_subscription\";s:0:\"\";s:10:\"support_kb\";N;s:13:\"support_forum\";N;s:13:\"support_email\";N;s:13:\"support_phone\";N;s:13:\"support_skype\";N;s:18:\"is_success_manager\";s:0:\"\";s:11:\"is_featured\";s:0:\"\";s:2:\"id\";s:4:\"Mzc0\";s:7:\"updated\";N;s:7:\"created\";s:28:\"MjAxNi0wNC0yNCAxNToyNzo0Nw==\";s:22:\"\0FS_Entity\0_is_updated\";b:0;}}}s:5:\"sites\";a:1:{s:15:\"nextgen-gallery\";O:7:\"FS_Site\":24:{s:4:\"slug\";s:15:\"nextgen-gallery\";s:7:\"site_id\";s:7:\"3388345\";s:9:\"plugin_id\";s:3:\"266\";s:7:\"user_id\";s:6:\"952081\";s:5:\"title\";s:10:\"Guy Shafir\";s:3:\"url\";s:20:\"http://104.155.81.48\";s:7:\"version\";s:6:\"2.2.33\";s:8:\"language\";s:5:\"en-US\";s:7:\"charset\";s:5:\"UTF-8\";s:16:\"platform_version\";s:5:\"4.9.4\";s:11:\"sdk_version\";s:7:\"1.2.1.5\";s:28:\"programming_language_version\";s:15:\"7.0.27-0+deb9u1\";s:4:\"plan\";O:14:\"FS_Plugin_Plan\":21:{s:9:\"plugin_id\";s:4:\"MjY2\";s:4:\"name\";s:8:\"ZnJlZQ==\";s:5:\"title\";s:8:\"RnJlZQ==\";s:11:\"description\";N;s:17:\"is_free_localhost\";s:4:\"MQ==\";s:17:\"is_block_features\";s:4:\"MQ==\";s:12:\"license_type\";s:4:\"MA==\";s:16:\"is_https_support\";s:0:\"\";s:12:\"trial_period\";N;s:23:\"is_require_subscription\";s:0:\"\";s:10:\"support_kb\";N;s:13:\"support_forum\";N;s:13:\"support_email\";N;s:13:\"support_phone\";N;s:13:\"support_skype\";N;s:18:\"is_success_manager\";s:0:\"\";s:11:\"is_featured\";s:0:\"\";s:2:\"id\";s:4:\"Mzc0\";s:7:\"updated\";N;s:7:\"created\";s:28:\"MjAxNi0wNC0yNCAxNToyNzo0Nw==\";s:22:\"\0FS_Entity\0_is_updated\";b:0;}s:10:\"license_id\";N;s:13:\"trial_plan_id\";N;s:10:\"trial_ends\";N;s:10:\"is_premium\";b:0;s:15:\"is_disconnected\";b:0;s:10:\"public_key\";s:32:\"pk_88856e8e5ea684d916feb8f1c8334\";s:10:\"secret_key\";s:32:\"sk_k=LF.U35m=45%=Fo{qApwROdus?iA\";s:2:\"id\";s:7:\"1229954\";s:7:\"updated\";N;s:7:\"created\";s:19:\"2018-02-07 21:48:17\";s:22:\"\0FS_Entity\0_is_updated\";b:0;}}s:11:\"all_plugins\";O:8:\"stdClass\":3:{s:9:\"timestamp\";i:1518076431;s:3:\"md5\";s:32:\"eddc08a68b717e8b6225b605ffdf4a47\";s:7:\"plugins\";a:7:{s:19:\"akismet/akismet.php\";a:5:{s:4:\"slug\";s:7:\"akismet\";s:7:\"version\";s:5:\"4.0.2\";s:5:\"title\";s:17:\"Akismet Anti-Spam\";s:9:\"is_active\";b:0;s:14:\"is_uninstalled\";b:0;}s:9:\"hello.php\";a:5:{s:4:\"slug\";s:11:\"hello-dolly\";s:7:\"version\";s:3:\"1.6\";s:5:\"title\";s:11:\"Hello Dolly\";s:9:\"is_active\";b:0;s:14:\"is_uninstalled\";b:0;}s:29:\"nextgen-gallery/nggallery.php\";a:5:{s:4:\"slug\";s:15:\"nextgen-gallery\";s:7:\"version\";s:6:\"2.2.33\";s:5:\"title\";s:15:\"NextGEN Gallery\";s:9:\"is_active\";b:1;s:14:\"is_uninstalled\";b:0;}s:27:\"thesography/exifography.php\";a:5:{s:4:\"slug\";s:11:\"thesography\";s:7:\"version\";s:3:\"1.3\";s:5:\"title\";s:11:\"Exifography\";s:9:\"is_active\";b:0;s:14:\"is_uninstalled\";b:0;}s:23:\"wp-smushit/wp-smush.php\";a:5:{s:4:\"slug\";s:10:\"wp-smushit\";s:7:\"version\";s:5:\"2.7.6\";s:5:\"title\";s:8:\"WP Smush\";s:9:\"is_active\";b:1;s:14:\"is_uninstalled\";b:0;}s:29:\"meow-gallery/meow-gallery.php\";a:5:{s:4:\"slug\";s:12:\"meow-gallery\";s:7:\"version\";s:5:\"1.0.7\";s:5:\"title\";s:12:\"Meow Gallery\";s:9:\"is_active\";b:1;s:14:\"is_uninstalled\";b:0;}s:31:\"meow-lightbox/meow-lightbox.php\";a:5:{s:4:\"slug\";s:13:\"meow-lightbox\";s:7:\"version\";s:5:\"1.0.9\";s:5:\"title\";s:13:\"Meow Lightbox\";s:9:\"is_active\";b:1;s:14:\"is_uninstalled\";b:0;}}}s:10:\"all_themes\";O:8:\"stdClass\":3:{s:9:\"timestamp\";i:1518076431;s:3:\"md5\";s:32:\"745627c11b61eab1d5bdbcceb53625a6\";s:6:\"themes\";a:5:{s:8:\"lucienne\";a:5:{s:4:\"slug\";s:8:\"lucienne\";s:7:\"version\";s:5:\"0.0.6\";s:5:\"title\";s:8:\"Lucienne\";s:9:\"is_active\";b:1;s:14:\"is_uninstalled\";b:0;}s:9:\"the-dylan\";a:5:{s:4:\"slug\";s:9:\"the-dylan\";s:7:\"version\";s:5:\"1.0.2\";s:5:\"title\";s:9:\"The Dylan\";s:9:\"is_active\";b:0;s:14:\"is_uninstalled\";b:0;}s:13:\"twentyfifteen\";a:5:{s:4:\"slug\";s:13:\"twentyfifteen\";s:7:\"version\";s:3:\"1.9\";s:5:\"title\";s:14:\"Twenty Fifteen\";s:9:\"is_active\";b:0;s:14:\"is_uninstalled\";b:0;}s:15:\"twentyseventeen\";a:5:{s:4:\"slug\";s:15:\"twentyseventeen\";s:7:\"version\";s:3:\"1.4\";s:5:\"title\";s:16:\"Twenty Seventeen\";s:9:\"is_active\";b:0;s:14:\"is_uninstalled\";b:0;}s:13:\"twentysixteen\";a:5:{s:4:\"slug\";s:13:\"twentysixteen\";s:7:\"version\";s:3:\"1.4\";s:5:\"title\";s:14:\"Twenty Sixteen\";s:9:\"is_active\";b:0;s:14:\"is_uninstalled\";b:0;}}}s:5:\"users\";a:1:{i:952081;O:7:\"FS_User\":12:{s:5:\"email\";s:19:\"guy210690@gmail.com\";s:5:\"first\";s:5:\"admin\";s:4:\"last\";s:0:\"\";s:11:\"is_verified\";b:0;s:11:\"customer_id\";N;s:5:\"gross\";i:0;s:10:\"public_key\";s:32:\"pk_5fd6b02245a3bf61228a70becb911\";s:10:\"secret_key\";s:32:\"sk_i=w>qldt(0sON2C:NVLqM&WNl3^Rj\";s:2:\"id\";s:6:\"952081\";s:7:\"updated\";N;s:7:\"created\";s:19:\"2018-02-07 21:48:17\";s:22:\"\0FS_Entity\0_is_updated\";b:0;}}s:8:\"licenses\";a:1:{s:15:\"nextgen-gallery\";a:1:{i:952081;b:0;}}s:13:\"admin_notices\";a:1:{s:15:\"nextgen-gallery\";a:0:{}}}', 'yes'),
(219, 'fs_api_cache', 'a:0:{}', 'yes'),
(221, 'widget_ngg-images', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(222, 'widget_ngg-mrssw', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(223, 'widget_slideshow', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(224, 'ngg_transient_groups', 'a:5:{s:9:\"__counter\";i:5;s:3:\"MVC\";a:2:{s:2:\"id\";i:2;s:7:\"enabled\";b:1;}s:15:\"col_in_wp_posts\";a:2:{s:2:\"id\";i:3;s:7:\"enabled\";b:1;}s:21:\"col_in_wp_ngg_gallery\";a:2:{s:2:\"id\";i:4;s:7:\"enabled\";b:1;}s:22:\"col_in_wp_ngg_pictures\";a:2:{s:2:\"id\";i:5;s:7:\"enabled\";b:1;}}', 'yes'),
(225, 'ngg_options', 'a:71:{s:11:\"gallerypath\";s:19:\"wp-content/gallery/\";s:11:\"wpmuCSSfile\";s:13:\"nggallery.css\";s:9:\"wpmuStyle\";b:0;s:9:\"wpmuRoles\";b:0;s:16:\"wpmuImportFolder\";b:0;s:13:\"wpmuZipUpload\";b:0;s:14:\"wpmuQuotaCheck\";b:0;s:17:\"datamapper_driver\";s:22:\"custom_post_datamapper\";s:21:\"gallerystorage_driver\";s:25:\"ngglegacy_gallery_storage\";s:20:\"maximum_entity_count\";i:500;s:17:\"router_param_slug\";s:9:\"nggallery\";s:22:\"router_param_separator\";s:2:\"--\";s:19:\"router_param_prefix\";s:0:\"\";s:9:\"deleteImg\";b:1;s:9:\"swfUpload\";b:1;s:13:\"usePermalinks\";b:0;s:13:\"permalinkSlug\";s:9:\"nggallery\";s:14:\"graphicLibrary\";s:2:\"gd\";s:14:\"imageMagickDir\";s:15:\"/usr/local/bin/\";s:11:\"useMediaRSS\";b:0;s:18:\"galleries_in_feeds\";b:0;s:12:\"activateTags\";i:0;s:10:\"appendType\";s:4:\"tags\";s:9:\"maxImages\";i:7;s:14:\"relatedHeading\";s:24:\"<h3>Related Images:</h3>\";s:10:\"thumbwidth\";i:240;s:11:\"thumbheight\";i:160;s:8:\"thumbfix\";b:1;s:12:\"thumbquality\";i:100;s:8:\"imgWidth\";i:800;s:9:\"imgHeight\";i:600;s:10:\"imgQuality\";i:100;s:9:\"imgBackup\";b:1;s:13:\"imgAutoResize\";b:0;s:9:\"galImages\";s:2:\"20\";s:17:\"galPagedGalleries\";i:0;s:10:\"galColumns\";i:0;s:12:\"galShowSlide\";b:1;s:12:\"galTextSlide\";s:16:\"[Show slideshow]\";s:14:\"galTextGallery\";s:17:\"[Show thumbnails]\";s:12:\"galShowOrder\";s:7:\"gallery\";s:7:\"galSort\";s:9:\"sortorder\";s:10:\"galSortDir\";s:3:\"ASC\";s:10:\"galNoPages\";b:1;s:13:\"galImgBrowser\";i:0;s:12:\"galHiddenImg\";i:0;s:10:\"galAjaxNav\";i:0;s:11:\"thumbEffect\";s:8:\"fancybox\";s:9:\"thumbCode\";s:41:\"class=\"ngg-fancybox\" rel=\"%GALLERY_NAME%\"\";s:18:\"thumbEffectContext\";s:14:\"nextgen_images\";s:5:\"wmPos\";s:8:\"botRight\";s:6:\"wmXpos\";i:5;s:6:\"wmYpos\";i:5;s:6:\"wmType\";s:5:\"image\";s:6:\"wmPath\";s:0:\"\";s:6:\"wmFont\";s:9:\"arial.ttf\";s:6:\"wmSize\";i:10;s:6:\"wmText\";s:10:\"Guy Shafir\";s:7:\"wmColor\";s:6:\"000000\";s:8:\"wmOpaque\";s:3:\"100\";s:7:\"slideFX\";s:4:\"fade\";s:7:\"irWidth\";i:600;s:8:\"irHeight\";i:400;s:12:\"irRotatetime\";i:10;s:11:\"activateCSS\";i:1;s:7:\"CSSfile\";s:13:\"nggallery.css\";s:28:\"always_enable_frontend_logic\";b:0;s:22:\"dynamic_thumbnail_slug\";s:13:\"nextgen-image\";s:23:\"dynamic_stylesheet_slug\";s:12:\"nextgen-dcss\";s:11:\"installDate\";i:1518040100;s:13:\"gallery_count\";i:0;}', 'yes'),
(227, 'photocrati_auto_update_admin_update_list', '', 'yes'),
(228, 'photocrati_auto_update_admin_check_date', '', 'yes'),
(229, 'ngg_db_version', '1.8.1', 'yes'),
(232, 'pope_module_list', 'a:1:{i:20;s:33:\"photocrati-dynamic_stylesheet|0.4\";}', 'yes'),
(250, 'wp-smush-hide_upgrade_notice', '1', 'no'),
(330, 'mwl_rating_date', '1526599965', 'no'),
(331, 'mgl_rating_date', '1524443798', 'no'),
(339, 'theme_mods_nepali', 'a:4:{i:0;b:0;s:18:\"nav_menu_locations\";a:0:{}s:18:\"custom_css_post_id\";i:-1;s:16:\"sidebars_widgets\";a:2:{s:4:\"time\";i:1518086952;s:4:\"data\";a:6:{s:19:\"wp_inactive_widgets\";a:3:{i:0;s:10:\"archives-2\";i:1;s:6:\"meta-2\";i:2;s:17:\"recent-comments-2\";}s:9:\"sidebar-1\";a:3:{i:0;s:8:\"search-2\";i:1;s:14:\"recent-posts-2\";i:2;s:12:\"categories-2\";}s:8:\"footer-1\";a:0:{}s:8:\"footer-2\";a:0:{}s:8:\"footer-3\";a:0:{}s:8:\"top-area\";a:0:{}}}}', 'yes'),
(340, 'widget_author-widget', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(344, 'theme_mods_kale', 'a:4:{i:0;b:0;s:18:\"nav_menu_locations\";a:0:{}s:18:\"custom_css_post_id\";i:-1;s:16:\"sidebars_widgets\";a:2:{s:4:\"time\";i:1518087124;s:4:\"data\";a:11:{s:19:\"wp_inactive_widgets\";a:3:{i:0;s:10:\"archives-2\";i:1;s:6:\"meta-2\";i:2;s:17:\"recent-comments-2\";}s:15:\"sidebar-default\";a:3:{i:0;s:8:\"search-2\";i:1;s:14:\"recent-posts-2\";i:2;s:12:\"categories-2\";}s:24:\"sidebar-default-bordered\";a:0:{}s:17:\"header-row-1-left\";a:0:{}s:18:\"header-row-1-right\";a:0:{}s:18:\"footer-row-2-col-1\";a:0:{}s:18:\"footer-row-2-col-2\";a:0:{}s:18:\"footer-row-2-col-3\";a:0:{}s:18:\"footer-row-2-col-4\";a:0:{}s:18:\"footer-row-2-col-5\";a:0:{}s:19:\"footer-row-3-center\";a:0:{}}}}', 'yes'),
(359, '_transient_is_multi_author', '0', 'yes'),
(360, '_transient_Lucienne_categories', '2', 'yes'),
(387, 'WPLANG', '', 'yes'),
(388, 'new_admin_email', 'guy210690@gmail.com', 'yes'),
(397, '_site_transient_update_themes', 'O:8:\"stdClass\":4:{s:12:\"last_checked\";i:1518437640;s:7:\"checked\";a:4:{s:8:\"lucienne\";s:5:\"0.0.6\";s:13:\"twentyfifteen\";s:3:\"1.9\";s:15:\"twentyseventeen\";s:3:\"1.4\";s:13:\"twentysixteen\";s:3:\"1.4\";}s:8:\"response\";a:0:{}s:12:\"translations\";a:0:{}}', 'no'),
(423, '_site_transient_timeout_theme_roots', '1518439439', 'no'),
(424, '_site_transient_theme_roots', 'a:4:{s:8:\"lucienne\";s:7:\"/themes\";s:13:\"twentyfifteen\";s:7:\"/themes\";s:15:\"twentyseventeen\";s:7:\"/themes\";s:13:\"twentysixteen\";s:7:\"/themes\";}', 'no'),
(425, '_site_transient_update_plugins', 'O:8:\"stdClass\":5:{s:12:\"last_checked\";i:1518437640;s:7:\"checked\";a:7:{s:19:\"akismet/akismet.php\";s:5:\"4.0.2\";s:27:\"thesography/exifography.php\";s:3:\"1.3\";s:9:\"hello.php\";s:3:\"1.6\";s:29:\"meow-gallery/meow-gallery.php\";s:5:\"1.0.7\";s:31:\"meow-lightbox/meow-lightbox.php\";s:5:\"1.0.9\";s:29:\"nextgen-gallery/nggallery.php\";s:6:\"2.2.33\";s:23:\"wp-smushit/wp-smush.php\";s:5:\"2.7.6\";}s:8:\"response\";a:1:{s:23:\"wp-smushit/wp-smush.php\";O:8:\"stdClass\":11:{s:2:\"id\";s:24:\"w.org/plugins/wp-smushit\";s:4:\"slug\";s:10:\"wp-smushit\";s:6:\"plugin\";s:23:\"wp-smushit/wp-smush.php\";s:11:\"new_version\";s:5:\"2.7.8\";s:3:\"url\";s:41:\"https://wordpress.org/plugins/wp-smushit/\";s:7:\"package\";s:59:\"https://downloads.wordpress.org/plugin/wp-smushit.2.7.8.zip\";s:5:\"icons\";a:3:{s:2:\"1x\";s:63:\"https://ps.w.org/wp-smushit/assets/icon-128x128.jpg?rev=1513049\";s:2:\"2x\";s:63:\"https://ps.w.org/wp-smushit/assets/icon-256x256.jpg?rev=1513049\";s:7:\"default\";s:63:\"https://ps.w.org/wp-smushit/assets/icon-256x256.jpg?rev=1513049\";}s:7:\"banners\";a:3:{s:2:\"2x\";s:66:\"https://ps.w.org/wp-smushit/assets/banner-1544x500.jpg?rev=1642596\";s:2:\"1x\";s:65:\"https://ps.w.org/wp-smushit/assets/banner-772x250.jpg?rev=1642596\";s:7:\"default\";s:66:\"https://ps.w.org/wp-smushit/assets/banner-1544x500.jpg?rev=1642596\";}s:11:\"banners_rtl\";a:0:{}s:6:\"tested\";s:5:\"4.9.4\";s:13:\"compatibility\";O:8:\"stdClass\":0:{}}}s:12:\"translations\";a:0:{}s:9:\"no_update\";a:6:{s:19:\"akismet/akismet.php\";O:8:\"stdClass\":9:{s:2:\"id\";s:21:\"w.org/plugins/akismet\";s:4:\"slug\";s:7:\"akismet\";s:6:\"plugin\";s:19:\"akismet/akismet.php\";s:11:\"new_version\";s:5:\"4.0.2\";s:3:\"url\";s:38:\"https://wordpress.org/plugins/akismet/\";s:7:\"package\";s:56:\"https://downloads.wordpress.org/plugin/akismet.4.0.2.zip\";s:5:\"icons\";a:3:{s:2:\"1x\";s:59:\"https://ps.w.org/akismet/assets/icon-128x128.png?rev=969272\";s:2:\"2x\";s:59:\"https://ps.w.org/akismet/assets/icon-256x256.png?rev=969272\";s:7:\"default\";s:59:\"https://ps.w.org/akismet/assets/icon-256x256.png?rev=969272\";}s:7:\"banners\";a:2:{s:2:\"1x\";s:61:\"https://ps.w.org/akismet/assets/banner-772x250.jpg?rev=479904\";s:7:\"default\";s:61:\"https://ps.w.org/akismet/assets/banner-772x250.jpg?rev=479904\";}s:11:\"banners_rtl\";a:0:{}}s:27:\"thesography/exifography.php\";O:8:\"stdClass\":9:{s:2:\"id\";s:25:\"w.org/plugins/thesography\";s:4:\"slug\";s:11:\"thesography\";s:6:\"plugin\";s:27:\"thesography/exifography.php\";s:11:\"new_version\";s:3:\"1.3\";s:3:\"url\";s:42:\"https://wordpress.org/plugins/thesography/\";s:7:\"package\";s:58:\"https://downloads.wordpress.org/plugin/thesography.1.3.zip\";s:5:\"icons\";a:3:{s:2:\"1x\";s:64:\"https://ps.w.org/thesography/assets/icon-128x128.png?rev=1506705\";s:2:\"2x\";s:64:\"https://ps.w.org/thesography/assets/icon-256x256.png?rev=1506705\";s:7:\"default\";s:64:\"https://ps.w.org/thesography/assets/icon-256x256.png?rev=1506705\";}s:7:\"banners\";a:3:{s:2:\"2x\";s:67:\"https://ps.w.org/thesography/assets/banner-1544x500.png?rev=1506705\";s:2:\"1x\";s:66:\"https://ps.w.org/thesography/assets/banner-772x250.png?rev=1506705\";s:7:\"default\";s:67:\"https://ps.w.org/thesography/assets/banner-1544x500.png?rev=1506705\";}s:11:\"banners_rtl\";a:0:{}}s:9:\"hello.php\";O:8:\"stdClass\":9:{s:2:\"id\";s:25:\"w.org/plugins/hello-dolly\";s:4:\"slug\";s:11:\"hello-dolly\";s:6:\"plugin\";s:9:\"hello.php\";s:11:\"new_version\";s:3:\"1.6\";s:3:\"url\";s:42:\"https://wordpress.org/plugins/hello-dolly/\";s:7:\"package\";s:58:\"https://downloads.wordpress.org/plugin/hello-dolly.1.6.zip\";s:5:\"icons\";a:3:{s:2:\"1x\";s:63:\"https://ps.w.org/hello-dolly/assets/icon-128x128.jpg?rev=969907\";s:2:\"2x\";s:63:\"https://ps.w.org/hello-dolly/assets/icon-256x256.jpg?rev=969907\";s:7:\"default\";s:63:\"https://ps.w.org/hello-dolly/assets/icon-256x256.jpg?rev=969907\";}s:7:\"banners\";a:2:{s:2:\"1x\";s:65:\"https://ps.w.org/hello-dolly/assets/banner-772x250.png?rev=478342\";s:7:\"default\";s:65:\"https://ps.w.org/hello-dolly/assets/banner-772x250.png?rev=478342\";}s:11:\"banners_rtl\";a:0:{}}s:29:\"meow-gallery/meow-gallery.php\";O:8:\"stdClass\":9:{s:2:\"id\";s:26:\"w.org/plugins/meow-gallery\";s:4:\"slug\";s:12:\"meow-gallery\";s:6:\"plugin\";s:29:\"meow-gallery/meow-gallery.php\";s:11:\"new_version\";s:5:\"1.0.7\";s:3:\"url\";s:43:\"https://wordpress.org/plugins/meow-gallery/\";s:7:\"package\";s:61:\"https://downloads.wordpress.org/plugin/meow-gallery.1.0.7.zip\";s:5:\"icons\";a:3:{s:2:\"1x\";s:65:\"https://ps.w.org/meow-gallery/assets/icon-128x128.png?rev=1518938\";s:2:\"2x\";s:65:\"https://ps.w.org/meow-gallery/assets/icon-256x256.png?rev=1518938\";s:7:\"default\";s:65:\"https://ps.w.org/meow-gallery/assets/icon-256x256.png?rev=1518938\";}s:7:\"banners\";a:3:{s:2:\"2x\";s:68:\"https://ps.w.org/meow-gallery/assets/banner-1544x500.png?rev=1518938\";s:2:\"1x\";s:67:\"https://ps.w.org/meow-gallery/assets/banner-772x250.png?rev=1518938\";s:7:\"default\";s:68:\"https://ps.w.org/meow-gallery/assets/banner-1544x500.png?rev=1518938\";}s:11:\"banners_rtl\";a:0:{}}s:31:\"meow-lightbox/meow-lightbox.php\";O:8:\"stdClass\":9:{s:2:\"id\";s:27:\"w.org/plugins/meow-lightbox\";s:4:\"slug\";s:13:\"meow-lightbox\";s:6:\"plugin\";s:31:\"meow-lightbox/meow-lightbox.php\";s:11:\"new_version\";s:5:\"1.0.9\";s:3:\"url\";s:44:\"https://wordpress.org/plugins/meow-lightbox/\";s:7:\"package\";s:62:\"https://downloads.wordpress.org/plugin/meow-lightbox.1.0.9.zip\";s:5:\"icons\";a:3:{s:2:\"1x\";s:66:\"https://ps.w.org/meow-lightbox/assets/icon-128x128.png?rev=1481590\";s:2:\"2x\";s:66:\"https://ps.w.org/meow-lightbox/assets/icon-256x256.png?rev=1481590\";s:7:\"default\";s:66:\"https://ps.w.org/meow-lightbox/assets/icon-256x256.png?rev=1481590\";}s:7:\"banners\";a:3:{s:2:\"2x\";s:69:\"https://ps.w.org/meow-lightbox/assets/banner-1544x500.png?rev=1481590\";s:2:\"1x\";s:68:\"https://ps.w.org/meow-lightbox/assets/banner-772x250.png?rev=1481590\";s:7:\"default\";s:69:\"https://ps.w.org/meow-lightbox/assets/banner-1544x500.png?rev=1481590\";}s:11:\"banners_rtl\";a:0:{}}s:29:\"nextgen-gallery/nggallery.php\";O:8:\"stdClass\":9:{s:2:\"id\";s:29:\"w.org/plugins/nextgen-gallery\";s:4:\"slug\";s:15:\"nextgen-gallery\";s:6:\"plugin\";s:29:\"nextgen-gallery/nggallery.php\";s:11:\"new_version\";s:6:\"2.2.33\";s:3:\"url\";s:46:\"https://wordpress.org/plugins/nextgen-gallery/\";s:7:\"package\";s:65:\"https://downloads.wordpress.org/plugin/nextgen-gallery.2.2.33.zip\";s:5:\"icons\";a:4:{s:2:\"1x\";s:68:\"https://ps.w.org/nextgen-gallery/assets/icon-128x128.png?rev=1537920\";s:2:\"2x\";s:68:\"https://ps.w.org/nextgen-gallery/assets/icon-256x256.png?rev=1537920\";s:3:\"svg\";s:60:\"https://ps.w.org/nextgen-gallery/assets/icon.svg?rev=1537920\";s:7:\"default\";s:60:\"https://ps.w.org/nextgen-gallery/assets/icon.svg?rev=1537920\";}s:7:\"banners\";a:2:{s:2:\"1x\";s:69:\"https://ps.w.org/nextgen-gallery/assets/banner-772x250.png?rev=667493\";s:7:\"default\";s:69:\"https://ps.w.org/nextgen-gallery/assets/banner-772x250.png?rev=667493\";}s:11:\"banners_rtl\";a:0:{}}}}', 'no');

-- --------------------------------------------------------

--
-- Table structure for table `wp_postmeta`
--

CREATE TABLE `wp_postmeta` (
  `meta_id` bigint(20) UNSIGNED NOT NULL,
  `post_id` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wp_postmeta`
--

INSERT INTO `wp_postmeta` (`meta_id`, `post_id`, `meta_key`, `meta_value`) VALUES
(1, 2, '_wp_page_template', 'default'),
(2, 4, '_edit_lock', '1518037952:1'),
(3, 4, '_customize_restore_dismissed', '1'),
(4, 5, '_wp_trash_meta_status', 'publish'),
(5, 5, '_wp_trash_meta_time', '1518038001'),
(6, 6, '_wp_attached_file', '2018/02/IMG_6056.jpg'),
(7, 6, '_wp_attachment_metadata', 'a:5:{s:5:\"width\";i:2048;s:6:\"height\";i:1365;s:4:\"file\";s:20:\"2018/02/IMG_6056.jpg\";s:5:\"sizes\";a:8:{s:9:\"thumbnail\";a:4:{s:4:\"file\";s:20:\"IMG_6056-150x150.jpg\";s:5:\"width\";i:150;s:6:\"height\";i:150;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:6:\"medium\";a:4:{s:4:\"file\";s:20:\"IMG_6056-300x200.jpg\";s:5:\"width\";i:300;s:6:\"height\";i:200;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:12:\"medium_large\";a:4:{s:4:\"file\";s:20:\"IMG_6056-768x512.jpg\";s:5:\"width\";i:768;s:6:\"height\";i:512;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:5:\"large\";a:4:{s:4:\"file\";s:21:\"IMG_6056-1024x683.jpg\";s:5:\"width\";i:1024;s:6:\"height\";i:683;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:13:\"Lucienne-home\";a:4:{s:4:\"file\";s:20:\"IMG_6056-900x450.jpg\";s:5:\"width\";i:900;s:6:\"height\";i:450;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:15:\"Lucienne-header\";a:4:{s:4:\"file\";s:21:\"IMG_6056-1400x400.jpg\";s:5:\"width\";i:1400;s:6:\"height\";i:400;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:21:\"Lucienne-carousel-pic\";a:4:{s:4:\"file\";s:20:\"IMG_6056-810x520.jpg\";s:5:\"width\";i:810;s:6:\"height\";i:520;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:18:\"Lucienne-site-logo\";a:4:{s:4:\"file\";s:20:\"IMG_6056-450x300.jpg\";s:5:\"width\";i:450;s:6:\"height\";i:300;s:9:\"mime-type\";s:10:\"image/jpeg\";}}s:10:\"image_meta\";a:12:{s:8:\"aperture\";s:3:\"1.4\";s:6:\"credit\";s:0:\"\";s:6:\"camera\";s:12:\"Canon EOS 6D\";s:7:\"caption\";s:0:\"\";s:17:\"created_timestamp\";s:10:\"1476878155\";s:9:\"copyright\";s:0:\"\";s:12:\"focal_length\";s:2:\"35\";s:3:\"iso\";s:3:\"100\";s:13:\"shutter_speed\";s:5:\"0.002\";s:5:\"title\";s:0:\"\";s:11:\"orientation\";s:1:\"1\";s:8:\"keywords\";a:0:{}}}'),
(8, 7, '_wp_attached_file', '2018/02/cropped-IMG_6056.jpg'),
(9, 7, '_wp_attachment_context', 'custom-header'),
(10, 7, '_wp_attachment_metadata', 'a:6:{s:5:\"width\";i:1600;s:6:\"height\";i:420;s:4:\"file\";s:28:\"2018/02/cropped-IMG_6056.jpg\";s:5:\"sizes\";a:8:{s:9:\"thumbnail\";a:4:{s:4:\"file\";s:28:\"cropped-IMG_6056-150x150.jpg\";s:5:\"width\";i:150;s:6:\"height\";i:150;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:6:\"medium\";a:4:{s:4:\"file\";s:27:\"cropped-IMG_6056-300x79.jpg\";s:5:\"width\";i:300;s:6:\"height\";i:79;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:12:\"medium_large\";a:4:{s:4:\"file\";s:28:\"cropped-IMG_6056-768x202.jpg\";s:5:\"width\";i:768;s:6:\"height\";i:202;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:5:\"large\";a:4:{s:4:\"file\";s:29:\"cropped-IMG_6056-1024x269.jpg\";s:5:\"width\";i:1024;s:6:\"height\";i:269;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:13:\"Lucienne-home\";a:4:{s:4:\"file\";s:28:\"cropped-IMG_6056-900x420.jpg\";s:5:\"width\";i:900;s:6:\"height\";i:420;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:15:\"Lucienne-header\";a:4:{s:4:\"file\";s:29:\"cropped-IMG_6056-1400x400.jpg\";s:5:\"width\";i:1400;s:6:\"height\";i:400;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:21:\"Lucienne-carousel-pic\";a:4:{s:4:\"file\";s:28:\"cropped-IMG_6056-810x420.jpg\";s:5:\"width\";i:810;s:6:\"height\";i:420;s:9:\"mime-type\";s:10:\"image/jpeg\";}s:18:\"Lucienne-site-logo\";a:4:{s:4:\"file\";s:29:\"cropped-IMG_6056-1000x263.jpg\";s:5:\"width\";i:1000;s:6:\"height\";i:263;s:9:\"mime-type\";s:10:\"image/jpeg\";}}s:10:\"image_meta\";a:12:{s:8:\"aperture\";s:1:\"0\";s:6:\"credit\";s:0:\"\";s:6:\"camera\";s:0:\"\";s:7:\"caption\";s:0:\"\";s:17:\"created_timestamp\";s:1:\"0\";s:9:\"copyright\";s:0:\"\";s:12:\"focal_length\";s:1:\"0\";s:3:\"iso\";s:1:\"0\";s:13:\"shutter_speed\";s:1:\"0\";s:5:\"title\";s:0:\"\";s:11:\"orientation\";s:1:\"0\";s:8:\"keywords\";a:0:{}}s:17:\"attachment_parent\";i:6;}'),
(11, 7, '_wp_attachment_custom_header_last_used_lucienne', '1518038322'),
(12, 7, '_wp_attachment_is_custom_header', 'nepali'),
(13, 8, '_wp_trash_meta_status', 'publish'),
(14, 8, '_wp_trash_meta_time', '1518038331'),
(15, 1, '_wp_trash_meta_status', 'publish'),
(16, 1, '_wp_trash_meta_time', '1518038403'),
(17, 1, '_wp_desired_post_slug', 'hello-world'),
(18, 1, '_wp_trash_meta_comments_status', 'a:1:{i:1;s:1:\"1\";}'),
(19, 10, '_edit_last', '1'),
(20, 10, '_edit_lock', '1518087378:1'),
(23, 2, '_wp_trash_meta_status', 'publish'),
(24, 2, '_wp_trash_meta_time', '1518038922'),
(25, 2, '_wp_desired_post_slug', 'sample-page'),
(28, 13, '_wp_trash_meta_status', 'publish'),
(29, 13, '_wp_trash_meta_time', '1518039223'),
(30, 7, 'wp-smpro-smush-data', 'a:2:{s:5:\"stats\";a:8:{s:7:\"percent\";d:4.8240063772859179;s:5:\"bytes\";i:18336;s:11:\"size_before\";i:380099;s:10:\"size_after\";i:361763;s:4:\"time\";d:0.42999999999999999;s:11:\"api_version\";s:3:\"1.0\";s:5:\"lossy\";b:0;s:9:\"keep_exif\";i:0;}s:5:\"sizes\";a:8:{s:9:\"thumbnail\";O:8:\"stdClass\":5:{s:7:\"percent\";d:7.7699999999999996;s:5:\"bytes\";i:623;s:11:\"size_before\";i:8013;s:10:\"size_after\";i:7390;s:4:\"time\";d:0.01;}s:6:\"medium\";O:8:\"stdClass\":5:{s:7:\"percent\";d:6.8200000000000003;s:5:\"bytes\";i:577;s:11:\"size_before\";i:8462;s:10:\"size_after\";i:7885;s:4:\"time\";d:0.01;}s:12:\"medium_large\";O:8:\"stdClass\":5:{s:7:\"percent\";d:5.4100000000000001;s:5:\"bytes\";i:1949;s:11:\"size_before\";i:36018;s:10:\"size_after\";i:34069;s:4:\"time\";d:0.02;}s:5:\"large\";O:8:\"stdClass\":5:{s:7:\"percent\";d:5.2000000000000002;s:5:\"bytes\";i:2874;s:11:\"size_before\";i:55304;s:10:\"size_after\";i:52430;s:4:\"time\";d:0.070000000000000007;}s:13:\"Lucienne-home\";O:8:\"stdClass\":5:{s:7:\"percent\";d:4.3099999999999996;s:5:\"bytes\";i:2875;s:11:\"size_before\";i:66714;s:10:\"size_after\";i:63839;s:4:\"time\";d:0.080000000000000002;}s:15:\"Lucienne-header\";O:8:\"stdClass\":5:{s:7:\"percent\";d:4.3399999999999999;s:5:\"bytes\";i:3947;s:11:\"size_before\";i:91046;s:10:\"size_after\";i:87099;s:4:\"time\";d:0.050000000000000003;}s:21:\"Lucienne-carousel-pic\";O:8:\"stdClass\":5:{s:7:\"percent\";d:4.3499999999999996;s:5:\"bytes\";i:2650;s:11:\"size_before\";i:60852;s:10:\"size_after\";i:58202;s:4:\"time\";d:0.13;}s:18:\"Lucienne-site-logo\";O:8:\"stdClass\":5:{s:7:\"percent\";d:5.29;s:5:\"bytes\";i:2841;s:11:\"size_before\";i:53690;s:10:\"size_after\";i:50849;s:4:\"time\";d:0.059999999999999998;}}}'),
(31, 6, 'wp-smush-resize_savings', 'a:3:{s:5:\"bytes\";i:5020486;s:11:\"size_before\";i:5365160;s:10:\"size_after\";i:344674;}'),
(32, 6, 'wp-smpro-smush-data', 'a:2:{s:5:\"stats\";a:8:{s:7:\"percent\";d:2.1673269634117922;s:5:\"bytes\";i:11067;s:11:\"size_before\";i:510629;s:10:\"size_after\";i:499562;s:4:\"time\";d:0.51000000000000001;s:11:\"api_version\";s:3:\"1.0\";s:5:\"lossy\";b:0;s:9:\"keep_exif\";i:0;}s:5:\"sizes\";a:8:{s:9:\"thumbnail\";O:8:\"stdClass\":5:{s:7:\"percent\";i:0;s:5:\"bytes\";i:0;s:11:\"size_before\";i:7929;s:10:\"size_after\";i:7929;s:4:\"time\";d:0.050000000000000003;}s:6:\"medium\";O:8:\"stdClass\":5:{s:7:\"percent\";i:0;s:5:\"bytes\";i:0;s:11:\"size_before\";i:17502;s:10:\"size_after\";i:17502;s:4:\"time\";d:0.01;}s:12:\"medium_large\";O:8:\"stdClass\":5:{s:7:\"percent\";i:0;s:5:\"bytes\";i:0;s:11:\"size_before\";i:75009;s:10:\"size_after\";i:75009;s:4:\"time\";d:0.050000000000000003;}s:5:\"large\";O:8:\"stdClass\":5:{s:7:\"percent\";i:0;s:5:\"bytes\";i:0;s:11:\"size_before\";i:117215;s:10:\"size_after\";i:117215;s:4:\"time\";d:0.059999999999999998;}s:13:\"Lucienne-home\";O:8:\"stdClass\":5:{s:7:\"percent\";i:0;s:5:\"bytes\";i:0;s:11:\"size_before\";i:76078;s:10:\"size_after\";i:76078;s:4:\"time\";d:0.050000000000000003;}s:15:\"Lucienne-header\";O:8:\"stdClass\":5:{s:7:\"percent\";d:4.4699999999999998;s:5:\"bytes\";i:4363;s:11:\"size_before\";i:97529;s:10:\"size_after\";i:93166;s:4:\"time\";d:0.13;}s:21:\"Lucienne-carousel-pic\";O:8:\"stdClass\":5:{s:7:\"percent\";d:5.46;s:5:\"bytes\";i:4594;s:11:\"size_before\";i:84168;s:10:\"size_after\";i:79574;s:4:\"time\";d:0.13;}s:18:\"Lucienne-site-logo\";O:8:\"stdClass\":5:{s:7:\"percent\";d:5.9900000000000002;s:5:\"bytes\";i:2110;s:11:\"size_before\";i:35199;s:10:\"size_after\";i:33089;s:4:\"time\";d:0.029999999999999999;}}}'),
(35, 10, '_use_exif', 'aperture,camera,focal_length,iso,shutter_speed'),
(36, 10, '_thumbnail_id', '6'),
(39, 15, 'title', 'NextGEN Basic Thumbnails'),
(40, 15, 'preview_image_relpath', '/nextgen-gallery/products/photocrati_nextgen/modules/nextgen_basic_gallery/static/thumb_preview.jpg'),
(41, 15, 'default_source', 'galleries'),
(42, 15, 'view_order', '10000'),
(43, 15, 'name', 'photocrati-nextgen_basic_thumbnails'),
(44, 15, 'installed_at_version', '2.2.33'),
(45, 15, 'hidden_from_ui', ''),
(46, 15, 'hidden_from_igw', ''),
(47, 15, '__defaults_set', '1'),
(48, 15, 'filter', 'raw'),
(49, 15, 'entity_types', 'WyJpbWFnZSJd'),
(50, 15, 'aliases', 'WyJiYXNpY190aHVtYm5haWwiLCJiYXNpY190aHVtYm5haWxzIiwibmV4dGdlbl9iYXNpY190aHVtYm5haWxzIl0='),
(51, 15, 'id_field', 'ID'),
(52, 15, 'settings', 'eyJ1c2VfbGlnaHRib3hfZWZmZWN0Ijp0cnVlLCJpbWFnZXNfcGVyX3BhZ2UiOiIyMCIsIm51bWJlcl9vZl9jb2x1bW5zIjowLCJ0aHVtYm5haWxfd2lkdGgiOjI0MCwidGh1bWJuYWlsX2hlaWdodCI6MTYwLCJzaG93X2FsbF9pbl9saWdodGJveCI6MCwiYWpheF9wYWdpbmF0aW9uIjowLCJ1c2VfaW1hZ2Vicm93c2VyX2VmZmVjdCI6MCwidGVtcGxhdGUiOiIiLCJkaXNwbGF5X25vX2ltYWdlc19lcnJvciI6MSwiZGlzYWJsZV9wYWdpbmF0aW9uIjowLCJzaG93X3NsaWRlc2hvd19saW5rIjoxLCJzbGlkZXNob3dfbGlua190ZXh0IjoiW1Nob3cgc2xpZGVzaG93XSIsIm92ZXJyaWRlX3RodW1ibmFpbF9zZXR0aW5ncyI6MCwidGh1bWJuYWlsX3F1YWxpdHkiOiIxMDAiLCJ0aHVtYm5haWxfY3JvcCI6MSwidGh1bWJuYWlsX3dhdGVybWFyayI6MCwibmdnX3RyaWdnZXJzX2Rpc3BsYXkiOiJuZXZlciIsIl9lcnJvcnMiOltdfQ=='),
(53, 16, 'title', 'NextGEN Basic Slideshow'),
(54, 16, 'preview_image_relpath', '/nextgen-gallery/products/photocrati_nextgen/modules/nextgen_basic_gallery/static/slideshow_preview.jpg'),
(55, 16, 'default_source', 'galleries'),
(56, 16, 'view_order', '10010'),
(57, 16, 'name', 'photocrati-nextgen_basic_slideshow'),
(58, 16, 'installed_at_version', '2.2.33'),
(59, 16, 'hidden_from_ui', ''),
(60, 16, 'hidden_from_igw', ''),
(61, 16, '__defaults_set', '1'),
(62, 16, 'filter', 'raw'),
(63, 16, 'entity_types', 'WyJpbWFnZSJd'),
(64, 16, 'aliases', 'WyJiYXNpY19zbGlkZXNob3ciLCJuZXh0Z2VuX2Jhc2ljX3NsaWRlc2hvdyJd'),
(65, 16, 'id_field', 'ID'),
(66, 16, 'settings', 'eyJ1c2VfbGlnaHRib3hfZWZmZWN0Ijp0cnVlLCJnYWxsZXJ5X3dpZHRoIjo2MDAsImdhbGxlcnlfaGVpZ2h0Ijo0MDAsInRodW1ibmFpbF93aWR0aCI6MjQwLCJ0aHVtYm5haWxfaGVpZ2h0IjoxNjAsImN5Y2xlX2ludGVydmFsIjoxMCwiY3ljbGVfZWZmZWN0IjoiZmFkZSIsImVmZmVjdF9jb2RlIjoiY2xhc3M9XCJuZ2ctZmFuY3lib3hcIiByZWw9XCIlR0FMTEVSWV9OQU1FJVwiIiwic2hvd190aHVtYm5haWxfbGluayI6MSwidGh1bWJuYWlsX2xpbmtfdGV4dCI6IltTaG93IHRodW1ibmFpbHNdIiwidGVtcGxhdGUiOiIiLCJuZ2dfdHJpZ2dlcnNfZGlzcGxheSI6Im5ldmVyIiwiX2Vycm9ycyI6W119'),
(67, 17, 'title', 'NextGEN Basic ImageBrowser'),
(68, 17, 'preview_image_relpath', '/nextgen-gallery/products/photocrati_nextgen/modules/nextgen_basic_imagebrowser/static/preview.jpg'),
(69, 17, 'default_source', 'galleries'),
(70, 17, 'view_order', '10020'),
(71, 17, 'name', 'photocrati-nextgen_basic_imagebrowser'),
(72, 17, 'installed_at_version', '2.2.33'),
(73, 17, 'hidden_from_ui', ''),
(74, 17, 'hidden_from_igw', ''),
(75, 17, '__defaults_set', '1'),
(76, 17, 'filter', 'raw'),
(77, 17, 'entity_types', 'WyJpbWFnZSJd'),
(78, 17, 'aliases', 'WyJiYXNpY19pbWFnZWJyb3dzZXIiLCJpbWFnZWJyb3dzZXIiLCJuZXh0Z2VuX2Jhc2ljX2ltYWdlYnJvd3NlciJd'),
(79, 17, 'id_field', 'ID'),
(80, 17, 'settings', 'eyJ1c2VfbGlnaHRib3hfZWZmZWN0Ijp0cnVlLCJ0ZW1wbGF0ZSI6IiIsIm5nZ190cmlnZ2Vyc19kaXNwbGF5IjoibmV2ZXIiLCJfZXJyb3JzIjpbXX0='),
(81, 18, 'title', 'NextGEN Basic SinglePic'),
(82, 18, 'preview_image_relpath', '/nextgen-gallery/products/photocrati_nextgen/modules/nextgen_basic_singlepic/static/preview.gif'),
(83, 18, 'default_source', 'galleries'),
(84, 18, 'view_order', '10060'),
(85, 18, 'hidden_from_ui', '1'),
(86, 18, 'hidden_from_igw', '1'),
(87, 18, 'name', 'photocrati-nextgen_basic_singlepic'),
(88, 18, 'installed_at_version', '2.2.33'),
(89, 18, '__defaults_set', '1'),
(90, 18, 'filter', 'raw'),
(91, 18, 'entity_types', 'WyJpbWFnZSJd'),
(92, 18, 'aliases', 'WyJiYXNpY19zaW5nbGVwaWMiLCJzaW5nbGVwaWMiLCJuZXh0Z2VuX2Jhc2ljX3NpbmdsZXBpYyJd'),
(93, 18, 'id_field', 'ID'),
(94, 18, 'settings', 'eyJ1c2VfbGlnaHRib3hfZWZmZWN0Ijp0cnVlLCJ3aWR0aCI6IiIsImhlaWdodCI6IiIsIm1vZGUiOiIiLCJkaXNwbGF5X3dhdGVybWFyayI6MCwiZGlzcGxheV9yZWZsZWN0aW9uIjowLCJmbG9hdCI6IiIsImxpbmsiOiIiLCJsaW5rX3RhcmdldCI6Il9ibGFuayIsInF1YWxpdHkiOjEwMCwiY3JvcCI6MCwidGVtcGxhdGUiOiIiLCJuZ2dfdHJpZ2dlcnNfZGlzcGxheSI6Im5ldmVyIiwiX2Vycm9ycyI6W119'),
(95, 19, 'title', 'NextGEN Basic TagCloud'),
(96, 19, 'preview_image_relpath', '/nextgen-gallery/products/photocrati_nextgen/modules/nextgen_basic_tagcloud/static/preview.gif'),
(97, 19, 'default_source', 'tags'),
(98, 19, 'view_order', '10100'),
(99, 19, 'name', 'photocrati-nextgen_basic_tagcloud'),
(100, 19, 'installed_at_version', '2.2.33'),
(101, 19, 'hidden_from_ui', ''),
(102, 19, 'hidden_from_igw', ''),
(103, 19, '__defaults_set', '1'),
(104, 19, 'filter', 'raw'),
(105, 19, 'entity_types', 'WyJpbWFnZSJd'),
(106, 19, 'aliases', 'WyJiYXNpY190YWdjbG91ZCIsInRhZ2Nsb3VkIiwibmV4dGdlbl9iYXNpY190YWdjbG91ZCJd'),
(107, 19, 'id_field', 'ID'),
(108, 19, 'settings', 'eyJ1c2VfbGlnaHRib3hfZWZmZWN0Ijp0cnVlLCJnYWxsZXJ5X2Rpc3BsYXlfdHlwZSI6InBob3RvY3JhdGktbmV4dGdlbl9iYXNpY190aHVtYm5haWxzIiwibnVtYmVyIjo0NSwibmdnX3RyaWdnZXJzX2Rpc3BsYXkiOiJuZXZlciIsIl9lcnJvcnMiOltdfQ=='),
(109, 20, 'title', 'NextGEN Basic Compact Album'),
(110, 20, 'preview_image_relpath', '/nextgen-gallery/products/photocrati_nextgen/modules/nextgen_basic_album/static/compact_preview.jpg'),
(111, 20, 'default_source', 'albums'),
(112, 20, 'view_order', '10200'),
(113, 20, 'name', 'photocrati-nextgen_basic_compact_album'),
(114, 20, 'installed_at_version', '2.2.33'),
(115, 20, 'hidden_from_ui', ''),
(116, 20, 'hidden_from_igw', ''),
(117, 20, '__defaults_set', '1'),
(118, 20, 'filter', 'raw'),
(119, 20, 'entity_types', 'WyJhbGJ1bSIsImdhbGxlcnkiXQ=='),
(120, 20, 'aliases', 'WyJiYXNpY19jb21wYWN0X2FsYnVtIiwibmV4dGdlbl9iYXNpY19hbGJ1bSIsImJhc2ljX2FsYnVtX2NvbXBhY3QiLCJjb21wYWN0X2FsYnVtIl0='),
(121, 20, 'id_field', 'ID'),
(122, 20, 'settings', 'eyJ1c2VfbGlnaHRib3hfZWZmZWN0Ijp0cnVlLCJnYWxsZXJpZXNfcGVyX3BhZ2UiOjAsImVuYWJsZV9icmVhZGNydW1icyI6MSwiZGlzYWJsZV9wYWdpbmF0aW9uIjowLCJlbmFibGVfZGVzY3JpcHRpb25zIjowLCJ0ZW1wbGF0ZSI6IiIsIm9wZW5fZ2FsbGVyeV9pbl9saWdodGJveCI6MCwiZ2FsbGVyeV9kaXNwbGF5X3R5cGUiOiJwaG90b2NyYXRpLW5leHRnZW5fYmFzaWNfdGh1bWJuYWlscyIsImdhbGxlcnlfZGlzcGxheV90ZW1wbGF0ZSI6IiIsIm5nZ190cmlnZ2Vyc19kaXNwbGF5IjoibmV2ZXIiLCJfZXJyb3JzIjpbXX0='),
(123, 21, 'title', 'NextGEN Basic Extended Album'),
(124, 21, 'preview_image_relpath', '/nextgen-gallery/products/photocrati_nextgen/modules/nextgen_basic_album/static/extended_preview.jpg'),
(125, 21, 'default_source', 'albums'),
(126, 21, 'view_order', '10210'),
(127, 21, 'name', 'photocrati-nextgen_basic_extended_album'),
(128, 21, 'installed_at_version', '2.2.33'),
(129, 21, 'hidden_from_ui', ''),
(130, 21, 'hidden_from_igw', ''),
(131, 21, '__defaults_set', '1'),
(132, 21, 'filter', 'raw'),
(133, 21, 'entity_types', 'WyJhbGJ1bSIsImdhbGxlcnkiXQ=='),
(134, 21, 'aliases', 'WyJiYXNpY19leHRlbmRlZF9hbGJ1bSIsIm5leHRnZW5fYmFzaWNfZXh0ZW5kZWRfYWxidW0iLCJleHRlbmRlZF9hbGJ1bSJd'),
(135, 21, 'id_field', 'ID'),
(136, 21, 'settings', 'eyJ1c2VfbGlnaHRib3hfZWZmZWN0Ijp0cnVlLCJnYWxsZXJpZXNfcGVyX3BhZ2UiOjAsImVuYWJsZV9icmVhZGNydW1icyI6MSwiZGlzYWJsZV9wYWdpbmF0aW9uIjowLCJlbmFibGVfZGVzY3JpcHRpb25zIjowLCJ0ZW1wbGF0ZSI6IiIsIm9wZW5fZ2FsbGVyeV9pbl9saWdodGJveCI6MCwib3ZlcnJpZGVfdGh1bWJuYWlsX3NldHRpbmdzIjowLCJ0aHVtYm5haWxfd2lkdGgiOjI0MCwidGh1bWJuYWlsX2hlaWdodCI6MTYwLCJ0aHVtYm5haWxfcXVhbGl0eSI6MTAwLCJ0aHVtYm5haWxfY3JvcCI6dHJ1ZSwidGh1bWJuYWlsX3dhdGVybWFyayI6MCwiZ2FsbGVyeV9kaXNwbGF5X3R5cGUiOiJwaG90b2NyYXRpLW5leHRnZW5fYmFzaWNfdGh1bWJuYWlscyIsImdhbGxlcnlfZGlzcGxheV90ZW1wbGF0ZSI6IiIsIm5nZ190cmlnZ2Vyc19kaXNwbGF5IjoibmV2ZXIiLCJfZXJyb3JzIjpbXX0='),
(137, 23, '_wp_attached_file', '2018/02/IMG_5972.jpg'),
(138, 23, '_wp_attachment_metadata', 'a:5:{s:5:\"width\";i:2048;s:6:\"height\";i:1365;s:4:\"file\";s:20:\"2018/02/IMG_5972.jpg\";s:5:\"sizes\";a:8:{s:9:\"thumbnail\";a:4:{s:4:\"file\";s:20:\"IMG_5972-150x150.jpg\";s:5:\"width\";s:3:\"150\";s:6:\"height\";s:3:\"150\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:6:\"medium\";a:4:{s:4:\"file\";s:20:\"IMG_5972-300x200.jpg\";s:5:\"width\";s:3:\"300\";s:6:\"height\";s:3:\"200\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:12:\"medium_large\";a:4:{s:4:\"file\";s:20:\"IMG_5972-768x512.jpg\";s:5:\"width\";s:3:\"768\";s:6:\"height\";s:3:\"512\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:5:\"large\";a:4:{s:4:\"file\";s:21:\"IMG_5972-1024x683.jpg\";s:5:\"width\";s:4:\"1024\";s:6:\"height\";s:3:\"683\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:13:\"Lucienne-home\";a:4:{s:4:\"file\";s:20:\"IMG_5972-900x450.jpg\";s:5:\"width\";s:3:\"900\";s:6:\"height\";s:3:\"450\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:15:\"Lucienne-header\";a:4:{s:4:\"file\";s:21:\"IMG_5972-1400x400.jpg\";s:5:\"width\";s:4:\"1400\";s:6:\"height\";s:3:\"400\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:21:\"Lucienne-carousel-pic\";a:4:{s:4:\"file\";s:20:\"IMG_5972-810x520.jpg\";s:5:\"width\";s:3:\"810\";s:6:\"height\";s:3:\"520\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:18:\"Lucienne-site-logo\";a:4:{s:4:\"file\";s:20:\"IMG_5972-450x300.jpg\";s:5:\"width\";s:3:\"450\";s:6:\"height\";s:3:\"300\";s:9:\"mime-type\";s:10:\"image/jpeg\";}}s:10:\"image_meta\";a:11:{s:8:\"aperture\";s:3:\"1.4\";s:6:\"credit\";s:0:\"\";s:6:\"camera\";s:12:\"Canon EOS 6D\";s:7:\"caption\";s:0:\"\";s:17:\"created_timestamp\";s:10:\"1476874329\";s:9:\"copyright\";s:0:\"\";s:12:\"focal_length\";s:2:\"35\";s:3:\"iso\";s:4:\"1600\";s:13:\"shutter_speed\";s:6:\"0.0125\";s:5:\"title\";s:0:\"\";s:11:\"orientation\";s:1:\"1\";}}'),
(139, 23, 'wp-smush-resize_savings', 'a:3:{s:5:\"bytes\";i:3904907;s:11:\"size_before\";i:4046434;s:10:\"size_after\";i:141527;}'),
(140, 23, 'wp-smpro-smush-data', 'a:2:{s:5:\"stats\";a:8:{s:7:\"percent\";d:1.8793845481924969;s:5:\"bytes\";i:4131;s:11:\"size_before\";i:219806;s:10:\"size_after\";i:215675;s:4:\"time\";d:0.35999999999999999;s:11:\"api_version\";s:3:\"1.0\";s:5:\"lossy\";b:0;s:9:\"keep_exif\";i:0;}s:5:\"sizes\";a:8:{s:9:\"thumbnail\";O:8:\"stdClass\":5:{s:7:\"percent\";d:4.5999999999999996;s:5:\"bytes\";i:229;s:11:\"size_before\";i:4983;s:10:\"size_after\";i:4754;s:4:\"time\";d:0.02;}s:6:\"medium\";O:8:\"stdClass\":5:{s:7:\"percent\";d:3.1099999999999999;s:5:\"bytes\";i:278;s:11:\"size_before\";i:8926;s:10:\"size_after\";i:8648;s:4:\"time\";d:0.029999999999999999;}s:12:\"medium_large\";O:8:\"stdClass\":5:{s:7:\"percent\";d:1.73;s:5:\"bytes\";i:570;s:11:\"size_before\";i:32986;s:10:\"size_after\";i:32416;s:4:\"time\";d:0.029999999999999999;}s:5:\"large\";O:8:\"stdClass\":5:{s:7:\"percent\";d:1.71;s:5:\"bytes\";i:845;s:11:\"size_before\";i:49519;s:10:\"size_after\";i:48674;s:4:\"time\";d:0.13;}s:13:\"Lucienne-home\";O:8:\"stdClass\":5:{s:7:\"percent\";d:1.71;s:5:\"bytes\";i:582;s:11:\"size_before\";i:33990;s:10:\"size_after\";i:33408;s:4:\"time\";d:0.029999999999999999;}s:15:\"Lucienne-header\";O:8:\"stdClass\":5:{s:7:\"percent\";d:1.8300000000000001;s:5:\"bytes\";i:713;s:11:\"size_before\";i:38891;s:10:\"size_after\";i:38178;s:4:\"time\";d:0.040000000000000001;}s:21:\"Lucienne-carousel-pic\";O:8:\"stdClass\":5:{s:7:\"percent\";d:1.6299999999999999;s:5:\"bytes\";i:568;s:11:\"size_before\";i:34794;s:10:\"size_after\";i:34226;s:4:\"time\";d:0.050000000000000003;}s:18:\"Lucienne-site-logo\";O:8:\"stdClass\":5:{s:7:\"percent\";d:2.2000000000000002;s:5:\"bytes\";i:346;s:11:\"size_before\";i:15717;s:10:\"size_after\";i:15371;s:4:\"time\";d:0.029999999999999999;}}}'),
(153, 30, '_wp_trash_meta_status', 'publish'),
(154, 30, '_wp_trash_meta_time', '1518041771'),
(155, 7, '_wp_attachment_custom_header_last_used_nepali', '1518086816'),
(157, 31, '_customize_restore_dismissed', '1'),
(158, 32, '_wp_attached_file', '2018/02/cropped-IMG_5972.jpg'),
(159, 32, '_wp_attachment_context', 'custom-header'),
(160, 32, '_wp_attachment_metadata', 'a:5:{s:5:\"width\";s:4:\"1500\";s:6:\"height\";s:3:\"687\";s:4:\"file\";s:28:\"2018/02/cropped-IMG_5972.jpg\";s:5:\"sizes\";a:7:{s:9:\"thumbnail\";a:4:{s:4:\"file\";s:28:\"cropped-IMG_5972-150x150.jpg\";s:5:\"width\";s:3:\"150\";s:6:\"height\";s:3:\"150\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:6:\"medium\";a:4:{s:4:\"file\";s:28:\"cropped-IMG_5972-300x137.jpg\";s:5:\"width\";s:3:\"300\";s:6:\"height\";s:3:\"137\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:12:\"medium_large\";a:4:{s:4:\"file\";s:28:\"cropped-IMG_5972-768x352.jpg\";s:5:\"width\";s:3:\"768\";s:6:\"height\";s:3:\"352\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:5:\"large\";a:4:{s:4:\"file\";s:29:\"cropped-IMG_5972-1024x469.jpg\";s:5:\"width\";s:4:\"1024\";s:6:\"height\";s:3:\"469\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:14:\"post-thumbnail\";a:4:{s:4:\"file\";s:28:\"cropped-IMG_5972-760x400.jpg\";s:5:\"width\";s:3:\"760\";s:6:\"height\";s:3:\"400\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:11:\"kale-slider\";a:4:{s:4:\"file\";s:29:\"cropped-IMG_5972-1200x550.jpg\";s:5:\"width\";s:4:\"1200\";s:6:\"height\";s:3:\"550\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:14:\"kale-thumbnail\";a:4:{s:4:\"file\";s:28:\"cropped-IMG_5972-760x400.jpg\";s:5:\"width\";s:3:\"760\";s:6:\"height\";s:3:\"400\";s:9:\"mime-type\";s:10:\"image/jpeg\";}}s:10:\"image_meta\";a:11:{s:8:\"aperture\";s:1:\"0\";s:6:\"credit\";s:0:\"\";s:6:\"camera\";s:0:\"\";s:7:\"caption\";s:0:\"\";s:17:\"created_timestamp\";s:1:\"0\";s:9:\"copyright\";s:0:\"\";s:12:\"focal_length\";s:1:\"0\";s:3:\"iso\";s:1:\"0\";s:13:\"shutter_speed\";s:1:\"0\";s:5:\"title\";s:0:\"\";s:11:\"orientation\";s:1:\"0\";}}'),
(161, 32, '_wp_attachment_custom_header_last_used_kale', '1518087018'),
(162, 32, '_wp_attachment_is_custom_header', 'kale'),
(163, 32, 'wp-smpro-smush-data', 'a:2:{s:5:\"stats\";a:8:{s:7:\"percent\";d:1.6704979132724798;s:5:\"bytes\";i:2994;s:11:\"size_before\";i:179228;s:10:\"size_after\";i:176234;s:4:\"time\";d:0.26000000000000001;s:11:\"api_version\";s:3:\"1.0\";s:5:\"lossy\";b:0;s:9:\"keep_exif\";i:0;}s:5:\"sizes\";a:7:{s:9:\"thumbnail\";O:8:\"stdClass\":5:{s:7:\"percent\";d:5.21;s:5:\"bytes\";i:250;s:11:\"size_before\";i:4794;s:10:\"size_after\";i:4544;s:4:\"time\";d:0.01;}s:6:\"medium\";O:8:\"stdClass\":5:{s:7:\"percent\";d:3.8399999999999999;s:5:\"bytes\";i:261;s:11:\"size_before\";i:6805;s:10:\"size_after\";i:6544;s:4:\"time\";d:0.01;}s:12:\"medium_large\";O:8:\"stdClass\":5:{s:7:\"percent\";d:1.9099999999999999;s:5:\"bytes\";i:480;s:11:\"size_before\";i:25127;s:10:\"size_after\";i:24647;s:4:\"time\";d:0.070000000000000007;}s:5:\"large\";O:8:\"stdClass\":5:{s:7:\"percent\";d:1.8600000000000001;s:5:\"bytes\";i:713;s:11:\"size_before\";i:38298;s:10:\"size_after\";i:37585;s:4:\"time\";d:0.040000000000000001;}s:14:\"post-thumbnail\";O:8:\"stdClass\":5:{s:7:\"percent\";d:1.8799999999999999;s:5:\"bytes\";i:533;s:11:\"size_before\";i:28426;s:10:\"size_after\";i:27893;s:4:\"time\";d:0.050000000000000003;}s:11:\"kale-slider\";O:8:\"stdClass\":5:{s:7:\"percent\";d:1.5800000000000001;s:5:\"bytes\";i:757;s:11:\"size_before\";i:47885;s:10:\"size_after\";i:47128;s:4:\"time\";d:0.050000000000000003;}s:14:\"kale-thumbnail\";O:8:\"stdClass\":5:{s:7:\"percent\";i:0;s:5:\"bytes\";i:0;s:11:\"size_before\";i:27893;s:10:\"size_after\";i:27893;s:4:\"time\";d:0.029999999999999999;}}}'),
(165, 34, '_wp_attached_file', '2018/02/IMG_9709.jpg'),
(166, 34, '_wp_attachment_metadata', 'a:5:{s:5:\"width\";i:2048;s:6:\"height\";i:1365;s:4:\"file\";s:20:\"2018/02/IMG_9709.jpg\";s:5:\"sizes\";a:8:{s:9:\"thumbnail\";a:4:{s:4:\"file\";s:20:\"IMG_9709-150x150.jpg\";s:5:\"width\";s:3:\"150\";s:6:\"height\";s:3:\"150\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:6:\"medium\";a:4:{s:4:\"file\";s:20:\"IMG_9709-300x200.jpg\";s:5:\"width\";s:3:\"300\";s:6:\"height\";s:3:\"200\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:12:\"medium_large\";a:4:{s:4:\"file\";s:20:\"IMG_9709-768x512.jpg\";s:5:\"width\";s:3:\"768\";s:6:\"height\";s:3:\"512\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:5:\"large\";a:4:{s:4:\"file\";s:21:\"IMG_9709-1024x683.jpg\";s:5:\"width\";s:4:\"1024\";s:6:\"height\";s:3:\"683\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:13:\"Lucienne-home\";a:4:{s:4:\"file\";s:20:\"IMG_9709-900x450.jpg\";s:5:\"width\";s:3:\"900\";s:6:\"height\";s:3:\"450\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:15:\"Lucienne-header\";a:4:{s:4:\"file\";s:21:\"IMG_9709-1400x400.jpg\";s:5:\"width\";s:4:\"1400\";s:6:\"height\";s:3:\"400\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:21:\"Lucienne-carousel-pic\";a:4:{s:4:\"file\";s:20:\"IMG_9709-810x520.jpg\";s:5:\"width\";s:3:\"810\";s:6:\"height\";s:3:\"520\";s:9:\"mime-type\";s:10:\"image/jpeg\";}s:18:\"Lucienne-site-logo\";a:4:{s:4:\"file\";s:20:\"IMG_9709-450x300.jpg\";s:5:\"width\";s:3:\"450\";s:6:\"height\";s:3:\"300\";s:9:\"mime-type\";s:10:\"image/jpeg\";}}s:10:\"image_meta\";a:11:{s:8:\"aperture\";s:3:\"2.8\";s:6:\"credit\";s:0:\"\";s:6:\"camera\";s:12:\"Canon EOS 6D\";s:7:\"caption\";s:0:\"\";s:17:\"created_timestamp\";s:10:\"1500720617\";s:9:\"copyright\";s:0:\"\";s:12:\"focal_length\";s:3:\"200\";s:3:\"iso\";s:3:\"100\";s:13:\"shutter_speed\";s:8:\"0.003125\";s:5:\"title\";s:0:\"\";s:11:\"orientation\";s:1:\"1\";}}'),
(167, 34, 'wp-smush-resize_savings', 'a:3:{s:5:\"bytes\";i:3990863;s:11:\"size_before\";i:4140618;s:10:\"size_after\";i:149755;}'),
(170, 33, '_customize_restore_dismissed', '1');

-- --------------------------------------------------------

--
-- Table structure for table `wp_posts`
--

CREATE TABLE `wp_posts` (
  `ID` bigint(20) UNSIGNED NOT NULL,
  `post_author` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_date_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_content` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_title` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_excerpt` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'publish',
  `comment_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `ping_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `post_password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `post_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `to_ping` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `pinged` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_modified_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_content_filtered` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_parent` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `guid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `menu_order` int(11) NOT NULL DEFAULT '0',
  `post_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'post',
  `post_mime_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `comment_count` bigint(20) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wp_posts`
--

INSERT INTO `wp_posts` (`ID`, `post_author`, `post_date`, `post_date_gmt`, `post_content`, `post_title`, `post_excerpt`, `post_status`, `comment_status`, `ping_status`, `post_password`, `post_name`, `to_ping`, `pinged`, `post_modified`, `post_modified_gmt`, `post_content_filtered`, `post_parent`, `guid`, `menu_order`, `post_type`, `post_mime_type`, `comment_count`) VALUES
(1, 1, '2018-02-07 11:58:18', '2018-02-07 11:58:18', 'Welcome to WordPress. This is your first post. Edit or delete it, then start writing!', 'Hello world!', '', 'trash', 'open', 'open', '', 'hello-world__trashed', '', '', '2018-02-07 21:20:03', '2018-02-07 21:20:03', '', 0, 'http://104.155.81.48/?p=1', 0, 'post', '', 1),
(2, 1, '2018-02-07 11:58:18', '2018-02-07 11:58:18', 'This is an example page. It\'s different from a blog post because it will stay in one place and will show up in your site navigation (in most themes). Most people start with an About page that introduces them to potential site visitors. It might say something like this:\n\n<blockquote>Hi there! I\'m a bike messenger by day, aspiring actor by night, and this is my website. I live in Los Angeles, have a great dog named Jack, and I like pi&#241;a coladas. (And gettin\' caught in the rain.)</blockquote>\n\n...or something like this:\n\n<blockquote>The XYZ Doohickey Company was founded in 1971, and has been providing quality doohickeys to the public ever since. Located in Gotham City, XYZ employs over 2,000 people and does all kinds of awesome things for the Gotham community.</blockquote>\n\nAs a new WordPress user, you should go to <a href=\"http://104.155.81.48/wp-admin/\">your dashboard</a> to delete this page and create new pages for your content. Have fun!', 'Sample Page', '', 'trash', 'closed', 'open', '', 'sample-page__trashed', '', '', '2018-02-07 21:28:42', '2018-02-07 21:28:42', '', 0, 'http://104.155.81.48/?page_id=2', 0, 'page', '', 0),
(3, 1, '2018-02-07 11:58:29', '0000-00-00 00:00:00', '', 'Auto Draft', '', 'auto-draft', 'open', 'open', '', '', '', '', '2018-02-07 11:58:29', '0000-00-00 00:00:00', '', 0, 'http://104.155.81.48/?p=3', 0, 'post', '', 0),
(4, 1, '2018-02-07 20:52:07', '0000-00-00 00:00:00', '{\n    \"blogname\": {\n        \"value\": \"Photo-Guy\",\n        \"type\": \"option\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 20:51:07\"\n    },\n    \"blogdescription\": {\n        \"value\": \"Just another photography blog\",\n        \"type\": \"option\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 20:51:07\"\n    },\n    \"lucienne::header_textcolor\": {\n        \"value\": \"#495762\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 20:51:07\"\n    },\n    \"show_on_front\": {\n        \"value\": \"posts\",\n        \"type\": \"option\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 20:51:07\"\n    },\n    \"sidebars_widgets[sidebar-1]\": {\n        \"value\": [\n            \"search-2\",\n            \"recent-posts-2\",\n            \"recent-comments-2\"\n        ],\n        \"type\": \"option\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 20:52:07\"\n    },\n    \"lucienne::show_main_slider\": {\n        \"value\": \"yes\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 20:52:07\"\n    }\n}', '', '', 'auto-draft', 'closed', 'closed', '', 'a4a21746-bb83-46cb-9b03-bf520a89b30d', '', '', '2018-02-07 20:52:07', '2018-02-07 20:52:07', '', 0, 'http://104.155.81.48/?p=4', 0, 'customize_changeset', '', 0),
(5, 1, '2018-02-07 21:13:21', '2018-02-07 21:13:21', '{\n    \"blogdescription\": {\n        \"value\": \"Just another photography blog\",\n        \"type\": \"option\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 21:13:21\"\n    }\n}', '', '', 'trash', 'closed', 'closed', '', '93941697-740b-4c7c-b334-015f6425002b', '', '', '2018-02-07 21:13:21', '2018-02-07 21:13:21', '', 0, 'http://104.155.81.48/index.php/2018/02/07/93941697-740b-4c7c-b334-015f6425002b/', 0, 'customize_changeset', '', 0),
(6, 1, '2018-02-07 21:18:15', '2018-02-07 21:18:15', '', 'IMG_6056', '', 'inherit', 'open', 'closed', '', 'img_6056', '', '', '2018-02-07 21:21:51', '2018-02-07 21:21:51', '', 10, 'http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056.jpg', 0, 'attachment', 'image/jpeg', 0),
(7, 1, '2018-02-07 21:18:41', '2018-02-07 21:18:41', '', 'cropped-IMG_6056.jpg', '', 'inherit', 'open', 'closed', '', 'cropped-img_6056-jpg', '', '', '2018-02-07 21:18:41', '2018-02-07 21:18:41', '', 0, 'http://104.155.81.48/wp-content/uploads/2018/02/cropped-IMG_6056.jpg', 0, 'attachment', 'image/jpeg', 0),
(8, 1, '2018-02-07 21:18:51', '2018-02-07 21:18:51', '{\n    \"lucienne::header_image\": {\n        \"value\": \"remove-header\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 21:18:51\"\n    },\n    \"lucienne::header_image_data\": {\n        \"value\": \"remove-header\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 21:18:51\"\n    }\n}', '', '', 'trash', 'closed', 'closed', '', '09f68408-2f20-4128-ac72-03f56f21a7f4', '', '', '2018-02-07 21:18:51', '2018-02-07 21:18:51', '', 0, 'http://104.155.81.48/index.php/2018/02/07/09f68408-2f20-4128-ac72-03f56f21a7f4/', 0, 'customize_changeset', '', 0),
(9, 1, '2018-02-07 21:20:03', '2018-02-07 21:20:03', 'Welcome to WordPress. This is your first post. Edit or delete it, then start writing!', 'Hello world!', '', 'inherit', 'closed', 'closed', '', '1-revision-v1', '', '', '2018-02-07 21:20:03', '2018-02-07 21:20:03', '', 1, 'http://104.155.81.48/index.php/2018/02/07/1-revision-v1/', 0, 'revision', '', 0),
(10, 1, '2018-02-07 21:27:57', '2018-02-07 21:27:57', 'On the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\r\n\r\n<img class=\"alignnone wp-image-23 size-full\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972.jpg\" alt=\"\" width=\"2048\" height=\"1365\" />\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 1600 | 1/80 sec</span>\r\n\r\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\r\n\r\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n<img class=\"alignnone wp-image-6 size-full\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056.jpg\" alt=\"\" width=\"2048\" height=\"1365\" />\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec</span>\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n<blockquote>&nbsp;</blockquote>', 'Romanian Autumn', '', 'publish', 'open', 'open', '', 'romanian-autumn', '', '', '2018-02-08 10:56:18', '2018-02-08 10:56:18', '', 0, 'http://104.155.81.48/?p=10', 0, 'post', '', 0),
(11, 1, '2018-02-07 21:27:57', '2018-02-07 21:27:57', '<img class=\"alignnone size-medium wp-image-6\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"300\" height=\"200\" />\r\n\r\nCanon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec\r\n\r\nThis picture was taken in Autumn of 2016 in Romania.\r\n\r\nOn the fifth day of our week long car trip through Romania we stopped at Bran, the famous residance of the infamous Vlad the Impaler. After a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n&nbsp;\r\n\r\n&nbsp;', 'Romanian Autumn', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-07 21:27:57', '2018-02-07 21:27:57', '', 10, 'http://104.155.81.48/index.php/2018/02/07/10-revision-v1/', 0, 'revision', '', 0),
(12, 1, '2018-02-07 21:28:42', '2018-02-07 21:28:42', 'This is an example page. It\'s different from a blog post because it will stay in one place and will show up in your site navigation (in most themes). Most people start with an About page that introduces them to potential site visitors. It might say something like this:\n\n<blockquote>Hi there! I\'m a bike messenger by day, aspiring actor by night, and this is my website. I live in Los Angeles, have a great dog named Jack, and I like pi&#241;a coladas. (And gettin\' caught in the rain.)</blockquote>\n\n...or something like this:\n\n<blockquote>The XYZ Doohickey Company was founded in 1971, and has been providing quality doohickeys to the public ever since. Located in Gotham City, XYZ employs over 2,000 people and does all kinds of awesome things for the Gotham community.</blockquote>\n\nAs a new WordPress user, you should go to <a href=\"http://104.155.81.48/wp-admin/\">your dashboard</a> to delete this page and create new pages for your content. Have fun!', 'Sample Page', '', 'inherit', 'closed', 'closed', '', '2-revision-v1', '', '', '2018-02-07 21:28:42', '2018-02-07 21:28:42', '', 2, 'http://104.155.81.48/index.php/2018/02/07/2-revision-v1/', 0, 'revision', '', 0),
(13, 1, '2018-02-07 21:33:43', '2018-02-07 21:33:43', '{\n    \"lucienne::carousel_setting\": {\n        \"value\": \"2\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 21:33:43\"\n    }\n}', '', '', 'trash', 'closed', 'closed', '', '53790da7-b23d-4362-9ff3-d8b3e6add470', '', '', '2018-02-07 21:33:43', '2018-02-07 21:33:43', '', 0, 'http://104.155.81.48/index.php/2018/02/07/53790da7-b23d-4362-9ff3-d8b3e6add470/', 0, 'customize_changeset', '', 0),
(14, 1, '2018-02-07 21:42:12', '2018-02-07 21:42:12', '<img class=\"alignnone  wp-image-6\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"612\" height=\"408\" />\r\n\r\nCanon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec\r\n\r\nThis picture was taken in Autumn of 2016 in Romania.\r\n\r\nOn the fifth day of our week long car trip through Romania we stopped at Bran, the famous residance of the infamous Vlad the Impaler. After a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n&nbsp;\r\n\r\n&nbsp;', 'Romanian Autumn', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-07 21:42:12', '2018-02-07 21:42:12', '', 10, 'http://104.155.81.48/index.php/2018/02/07/10-revision-v1/', 0, 'revision', '', 0),
(22, 1, '2018-02-08 10:54:01', '2018-02-08 10:54:01', 'On the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\n\n<img class=\" wp-image-23 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972-300x200.jpg\" alt=\"\" width=\"611\" height=\"407\" />\n\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 1600 | 1/80 sec</span>\n\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\n\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\n\n<img class=\"wp-image-6 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"612\" height=\"408\" />\n\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec</span>\n\n&nbsp;\n\n&nbsp;\n\n&nbsp;\n\n&nbsp;\n\n&nbsp;\n\n&nbsp;\n\n&nbsp;\n\n&nbsp;\n\n&nbsp;\n\n&nbsp;\n<blockquote>&nbsp;</blockquote>', 'Romanian Autumn #5', '', 'inherit', 'closed', 'closed', '', '10-autosave-v1', '', '', '2018-02-08 10:54:01', '2018-02-08 10:54:01', '', 10, 'http://104.155.81.48/index.php/2018/02/07/10-autosave-v1/', 0, 'revision', '', 0),
(23, 1, '2018-02-07 21:55:42', '2018-02-07 21:55:42', '', 'IMG_5972', '', 'inherit', 'open', 'closed', '', 'img_5972', '', '', '2018-02-07 21:55:42', '2018-02-07 21:55:42', '', 10, 'http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972.jpg', 0, 'attachment', 'image/jpeg', 0),
(24, 1, '2018-02-07 22:04:07', '2018-02-07 22:04:07', '&nbsp;\r\n\r\nThis picture was taken in Autumn of 2016 in Romania.\r\n\r\nOn the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\r\n\r\n<img class=\" wp-image-23 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972-300x200.jpg\" alt=\"\" width=\"611\" height=\"407\">\r\n<blockquote>Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 1600 | 1/80 sec</blockquote>\r\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\r\n\r\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n<img class=\"wp-image-6 alignleft\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"612\" height=\"408\">\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n<blockquote>Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec</blockquote>', 'Romanian Autumn', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-07 22:04:07', '2018-02-07 22:04:07', '', 10, 'http://104.155.81.48/index.php/2018/02/07/10-revision-v1/', 0, 'revision', '', 0),
(25, 1, '2018-02-07 22:05:43', '2018-02-07 22:05:43', 'On the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\r\n\r\n<img class=\" wp-image-23 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972-300x200.jpg\" alt=\"\" width=\"611\" height=\"407\">\r\n<pre>Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 1600 | 1/80 sec</pre>\r\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\r\n\r\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n<img class=\"wp-image-6 alignleft\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"612\" height=\"408\">\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n<blockquote>&nbsp;</blockquote>\r\n<pre>Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec</pre>', 'Romanian Autumn', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-07 22:05:43', '2018-02-07 22:05:43', '', 10, 'http://104.155.81.48/index.php/2018/02/07/10-revision-v1/', 0, 'revision', '', 0),
(26, 1, '2018-02-07 22:11:16', '2018-02-07 22:11:16', 'On the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\r\n\r\n<img class=\" wp-image-23 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972-300x200.jpg\" alt=\"\" width=\"611\" height=\"407\">\r\n<pre>Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 1600 | 1/80 sec</pre>\r\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\r\n\r\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n<img class=\"wp-image-6 alignleft\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"612\" height=\"408\">\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n<blockquote>&nbsp;</blockquote>\r\n<span style=\"font-family: Consolas, Monaco, monospace;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec</span>', 'Romanian Autumn', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-07 22:11:16', '2018-02-07 22:11:16', '', 10, 'http://104.155.81.48/index.php/2018/02/07/10-revision-v1/', 0, 'revision', '', 0),
(27, 1, '2018-02-07 22:12:13', '2018-02-07 22:12:13', 'On the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\r\n\r\n<img class=\" wp-image-23 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972-300x200.jpg\" alt=\"\" width=\"611\" height=\"407\">\r\n\r\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\r\n\r\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n<img class=\"wp-image-6 alignleft\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"612\" height=\"408\">\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n<blockquote>&nbsp;</blockquote>', 'Romanian Autumn', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-07 22:12:13', '2018-02-07 22:12:13', '', 10, 'http://104.155.81.48/index.php/2018/02/07/10-revision-v1/', 0, 'revision', '', 0),
(28, 1, '2018-02-07 22:13:29', '2018-02-07 22:13:29', 'On the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\r\n\r\n<img class=\" wp-image-23 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972-300x200.jpg\" alt=\"\" width=\"611\" height=\"407\">\r\n\r\nCanon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 1600 | 1/80 sec\r\n\r\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\r\n\r\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n<img class=\"wp-image-6 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"612\" height=\"408\">\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec</span>\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n<blockquote>&nbsp;</blockquote>', 'Romanian Autumn', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-07 22:13:29', '2018-02-07 22:13:29', '', 10, 'http://104.155.81.48/index.php/2018/02/07/10-revision-v1/', 0, 'revision', '', 0),
(29, 1, '2018-02-07 22:13:42', '2018-02-07 22:13:42', 'On the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\r\n\r\n<img class=\" wp-image-23 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972-300x200.jpg\" alt=\"\" width=\"611\" height=\"407\">\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 1600 | 1/80 sec</span>\r\n\r\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\r\n\r\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n<img class=\"wp-image-6 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"612\" height=\"408\">\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec</span>\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n<blockquote>&nbsp;</blockquote>', 'Romanian Autumn', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-07 22:13:42', '2018-02-07 22:13:42', '', 10, 'http://104.155.81.48/index.php/2018/02/07/10-revision-v1/', 0, 'revision', '', 0),
(30, 1, '2018-02-07 22:16:11', '2018-02-07 22:16:11', '{\n    \"sidebars_widgets[sidebar-1]\": {\n        \"value\": [\n            \"search-2\",\n            \"recent-posts-2\",\n            \"categories-2\"\n        ],\n        \"type\": \"option\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-07 22:16:11\"\n    }\n}', '', '', 'trash', 'closed', 'closed', '', '7f592f44-c8a9-4ecf-a5c2-d8da326eb4eb', '', '', '2018-02-07 22:16:11', '2018-02-07 22:16:11', '', 0, 'http://104.155.81.48/index.php/2018/02/07/7f592f44-c8a9-4ecf-a5c2-d8da326eb4eb/', 0, 'customize_changeset', '', 0),
(31, 1, '2018-02-08 10:47:37', '0000-00-00 00:00:00', '{\n    \"nepali::header_image\": {\n        \"value\": \"remove-header\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:47:37\"\n    },\n    \"nepali::header_image_data\": {\n        \"value\": \"remove-header\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:47:37\"\n    },\n    \"nepali::words_theme_options[words-blog-content]\": {\n        \"value\": false,\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:47:37\"\n    },\n    \"nepali::words_theme_options[words-sticky-sidebar-option]\": {\n        \"value\": false,\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:47:37\"\n    }\n}', '', '', 'auto-draft', 'closed', 'closed', '', 'ce8308e9-9819-44ca-89b2-99f0fc4b72c7', '', '', '2018-02-08 10:47:37', '0000-00-00 00:00:00', '', 0, 'http://104.155.81.48/?p=31', 0, 'customize_changeset', '', 0),
(32, 1, '2018-02-08 10:50:17', '2018-02-08 10:50:17', '', 'cropped-IMG_5972.jpg', '', 'inherit', 'open', 'closed', '', 'cropped-img_5972-jpg', '', '', '2018-02-08 10:50:17', '2018-02-08 10:50:17', '', 0, 'http://104.155.81.48/wp-content/uploads/2018/02/cropped-IMG_5972.jpg', 0, 'attachment', 'image/jpeg', 0),
(33, 1, '2018-02-08 10:51:42', '0000-00-00 00:00:00', '{\n    \"blogdescription\": {\n        \"value\": \"\",\n        \"type\": \"option\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:50:42\"\n    },\n    \"kale::header_image\": {\n        \"value\": \"http://104.155.81.48/wp-content/uploads/2018/02/cropped-IMG_5972.jpg\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:50:42\"\n    },\n    \"kale::header_image_data\": {\n        \"value\": {\n            \"url\": \"http://104.155.81.48/wp-content/uploads/2018/02/cropped-IMG_5972.jpg\",\n            \"thumbnail_url\": \"http://104.155.81.48/wp-content/uploads/2018/02/cropped-IMG_5972.jpg\",\n            \"timestamp\": 1518087016756,\n            \"attachment_id\": 32,\n            \"width\": 1500,\n            \"height\": 687\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:50:42\"\n    },\n    \"kale::kale_example_content\": {\n        \"value\": false,\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:50:42\"\n    },\n    \"kale::kale_frontpage_posts_slider_category\": {\n        \"value\": \"2\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:50:42\"\n    },\n    \"kale::kale_blog_feed_comments_show\": {\n        \"value\": true,\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:51:42\"\n    },\n    \"kale::kale_posts_sidebar\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2018-02-08 10:51:42\"\n    }\n}', '', '', 'auto-draft', 'closed', 'closed', '', 'bae16333-049f-4ca4-a01e-8a753ab9666a', '', '', '2018-02-08 10:51:42', '2018-02-08 10:51:42', '', 0, 'http://104.155.81.48/?p=33', 0, 'customize_changeset', '', 0),
(34, 1, '2018-02-08 10:53:49', '2018-02-08 10:53:49', '', 'IMG_9709', '', 'inherit', 'open', 'closed', '', 'img_9709', '', '', '2018-02-08 10:53:49', '2018-02-08 10:53:49', '', 10, 'http://104.155.81.48/wp-content/uploads/2018/02/IMG_9709.jpg', 0, 'attachment', 'image/jpeg', 0),
(35, 1, '2018-02-08 10:54:32', '2018-02-08 10:54:32', 'On the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\r\n\r\n<img class=\" wp-image-23 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972-300x200.jpg\" alt=\"\" width=\"611\" height=\"407\" />\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 1600 | 1/80 sec</span>\r\n\r\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\r\n\r\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n<img class=\"wp-image-6 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"612\" height=\"408\" />\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec</span>\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n<img class=\"alignnone  wp-image-34\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_9709-300x200.jpg\" alt=\"\" width=\"755\" height=\"503\" />\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n<blockquote>&nbsp;</blockquote>', 'Romanian Autumn #5', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-08 10:54:32', '2018-02-08 10:54:32', '', 10, 'http://104.155.81.48/index.php/2018/02/08/10-revision-v1/', 0, 'revision', '', 0),
(36, 1, '2018-02-08 10:55:30', '2018-02-08 10:55:30', 'On the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\r\n\r\n<img class=\" wp-image-23 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972-300x200.jpg\" alt=\"\" width=\"611\" height=\"407\" />\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 1600 | 1/80 sec</span>\r\n\r\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\r\n\r\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n<img class=\"wp-image-6 alignnone\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056-300x200.jpg\" alt=\"\" width=\"612\" height=\"408\" />\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec</span>\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n<a href=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_9709.jpg\"><img class=\"alignnone wp-image-34 size-full\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_9709.jpg\" alt=\"\" width=\"2048\" height=\"1365\" /></a>\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n<blockquote>&nbsp;</blockquote>', 'Romanian Autumn #5', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-08 10:55:30', '2018-02-08 10:55:30', '', 10, 'http://104.155.81.48/index.php/2018/02/08/10-revision-v1/', 0, 'revision', '', 0),
(37, 1, '2018-02-08 10:56:18', '2018-02-08 10:56:18', 'On the fifth day of our week long car trip through Romania we stopped at Bran, the famous residence of the infamous Vlad the Impaler. It\'s definitely not a huge climb to the castle, but it is damn worth it. Once you enter the castle, you are greeted by narrow passages and very steep though short stairs (seems people in the past were slimmer and had longer legs and very tiny feet).\r\n\r\n<img class=\"alignnone wp-image-23 size-full\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_5972.jpg\" alt=\"\" width=\"2048\" height=\"1365\" />\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 1600 | 1/80 sec</span>\r\n\r\nThe rooms are pretty small, and decorated very differently from one another. Each resident of the castle had their own taste.\r\n\r\nAfter a tour in the castle, we have decided to take to the grounds. I lagged behind on our little group of photography enthusiasts to take a picture of every yellow-orange leaf possible until I stumbled upon this unexpected candy land.\r\n\r\n<img class=\"alignnone wp-image-6 size-full\" src=\"http://104.155.81.48/wp-content/uploads/2018/02/IMG_6056.jpg\" alt=\"\" width=\"2048\" height=\"1365\" />\r\n\r\n<span style=\"color: #808080;\">Canon 6d| Sigma Art 35mm f1.4 @ f1.4 | ISO 100 | 1/500 sec</span>\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n\r\n&nbsp;\r\n<blockquote>&nbsp;</blockquote>', 'Romanian Autumn', '', 'inherit', 'closed', 'closed', '', '10-revision-v1', '', '', '2018-02-08 10:56:18', '2018-02-08 10:56:18', '', 10, 'http://104.155.81.48/index.php/2018/02/08/10-revision-v1/', 0, 'revision', '', 0);

-- --------------------------------------------------------

--
-- Table structure for table `wp_smush_dir_images`
--

CREATE TABLE `wp_smush_dir_images` (
  `id` mediumint(9) NOT NULL,
  `path` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `resize` varchar(55) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lossy` varchar(55) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `error` varchar(55) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_size` int(10) UNSIGNED DEFAULT NULL,
  `orig_size` int(10) UNSIGNED DEFAULT NULL,
  `file_time` int(10) UNSIGNED DEFAULT NULL,
  `last_scan` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `meta` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wp_termmeta`
--

CREATE TABLE `wp_termmeta` (
  `meta_id` bigint(20) UNSIGNED NOT NULL,
  `term_id` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wp_terms`
--

CREATE TABLE `wp_terms` (
  `term_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `slug` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `term_group` bigint(10) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wp_terms`
--

INSERT INTO `wp_terms` (`term_id`, `name`, `slug`, `term_group`) VALUES
(1, 'Uncategorized', 'uncategorized', 0),
(2, 'Romania', 'romania', 0),
(3, 'Autumn', 'autumn', 0);

-- --------------------------------------------------------

--
-- Table structure for table `wp_term_relationships`
--

CREATE TABLE `wp_term_relationships` (
  `object_id` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `term_taxonomy_id` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `term_order` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wp_term_relationships`
--

INSERT INTO `wp_term_relationships` (`object_id`, `term_taxonomy_id`, `term_order`) VALUES
(1, 1, 0),
(10, 2, 0),
(10, 3, 0);

-- --------------------------------------------------------

--
-- Table structure for table `wp_term_taxonomy`
--

CREATE TABLE `wp_term_taxonomy` (
  `term_taxonomy_id` bigint(20) UNSIGNED NOT NULL,
  `term_id` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `taxonomy` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `count` bigint(20) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wp_term_taxonomy`
--

INSERT INTO `wp_term_taxonomy` (`term_taxonomy_id`, `term_id`, `taxonomy`, `description`, `parent`, `count`) VALUES
(1, 1, 'category', '', 0, 0),
(2, 2, 'category', '', 0, 1),
(3, 3, 'category', '', 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `wp_usermeta`
--

CREATE TABLE `wp_usermeta` (
  `umeta_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wp_usermeta`
--

INSERT INTO `wp_usermeta` (`umeta_id`, `user_id`, `meta_key`, `meta_value`) VALUES
(1, 1, 'nickname', 'admin'),
(2, 1, 'first_name', ''),
(3, 1, 'last_name', ''),
(4, 1, 'description', ''),
(5, 1, 'rich_editing', 'true'),
(6, 1, 'syntax_highlighting', 'true'),
(7, 1, 'comment_shortcuts', 'false'),
(8, 1, 'admin_color', 'fresh'),
(9, 1, 'use_ssl', '0'),
(10, 1, 'show_admin_bar_front', 'true'),
(11, 1, 'locale', ''),
(12, 1, 'wp_capabilities', 'a:1:{s:13:\"administrator\";b:1;}'),
(13, 1, 'wp_user_level', '10'),
(14, 1, 'dismissed_wp_pointers', 'theme_editor_notice'),
(15, 1, 'show_welcome_panel', '1'),
(16, 1, 'session_tokens', 'a:3:{s:64:\"9e797f85d7144381fa4b119aaca8f7d3bb06398bb8d6cf779d5eacae7e99b6e9\";a:4:{s:10:\"expiration\";i:1518209137;s:2:\"ip\";s:13:\"5.102.232.120\";s:2:\"ua\";s:114:\"Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36\";s:5:\"login\";i:1518036337;}s:64:\"93a70efe4b4461a55daecf5f0cd6b3a772746214a97e8deddee721d1d424e91e\";a:4:{s:10:\"expiration\";i:1518249158;s:2:\"ip\";s:13:\"62.219.124.87\";s:2:\"ua\";s:115:\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36\";s:5:\"login\";i:1518076358;}s:64:\"113f12266098293cf6e43f4eecc530a68930b3592cd2f4ba43a47d5fb66c34d4\";a:4:{s:10:\"expiration\";i:1518377393;s:2:\"ip\";s:13:\"5.102.232.120\";s:2:\"ua\";s:114:\"Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36\";s:5:\"login\";i:1518204593;}}'),
(17, 1, 'wp_dashboard_quick_press_last_post_id', '3'),
(18, 1, 'community-events-location', 'a:1:{s:2:\"ip\";s:11:\"5.102.232.0\";}'),
(19, 1, 'wp_user-settings', 'libraryContent=browse&hidetb=1&editor=tinymce&advImgDetails=show'),
(20, 1, 'wp_user-settings-time', '1518076597');

-- --------------------------------------------------------

--
-- Table structure for table `wp_users`
--

CREATE TABLE `wp_users` (
  `ID` bigint(20) UNSIGNED NOT NULL,
  `user_login` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_pass` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_nicename` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_url` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_registered` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `user_activation_key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_status` int(11) NOT NULL DEFAULT '0',
  `display_name` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wp_users`
--

INSERT INTO `wp_users` (`ID`, `user_login`, `user_pass`, `user_nicename`, `user_email`, `user_url`, `user_registered`, `user_activation_key`, `user_status`, `display_name`) VALUES
(1, 'admin', '$P$BtxTrMlGgHpdAr3sZ.mUo2LhxrK/Hx/', 'admin', 'guy210690@gmail.com', '', '2018-02-07 11:58:18', '', 0, 'admin');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `wp_commentmeta`
--
ALTER TABLE `wp_commentmeta`
  ADD PRIMARY KEY (`meta_id`),
  ADD KEY `comment_id` (`comment_id`),
  ADD KEY `meta_key` (`meta_key`(191));

--
-- Indexes for table `wp_comments`
--
ALTER TABLE `wp_comments`
  ADD PRIMARY KEY (`comment_ID`),
  ADD KEY `comment_post_ID` (`comment_post_ID`),
  ADD KEY `comment_approved_date_gmt` (`comment_approved`,`comment_date_gmt`),
  ADD KEY `comment_date_gmt` (`comment_date_gmt`),
  ADD KEY `comment_parent` (`comment_parent`),
  ADD KEY `comment_author_email` (`comment_author_email`(10));

--
-- Indexes for table `wp_links`
--
ALTER TABLE `wp_links`
  ADD PRIMARY KEY (`link_id`),
  ADD KEY `link_visible` (`link_visible`);

--
-- Indexes for table `wp_ngg_album`
--
ALTER TABLE `wp_ngg_album`
  ADD PRIMARY KEY (`id`),
  ADD KEY `extras_post_id_key` (`extras_post_id`);

--
-- Indexes for table `wp_ngg_gallery`
--
ALTER TABLE `wp_ngg_gallery`
  ADD PRIMARY KEY (`gid`),
  ADD KEY `extras_post_id_key` (`extras_post_id`);

--
-- Indexes for table `wp_ngg_pictures`
--
ALTER TABLE `wp_ngg_pictures`
  ADD PRIMARY KEY (`pid`),
  ADD KEY `extras_post_id_key` (`extras_post_id`);

--
-- Indexes for table `wp_options`
--
ALTER TABLE `wp_options`
  ADD PRIMARY KEY (`option_id`),
  ADD UNIQUE KEY `option_name` (`option_name`);

--
-- Indexes for table `wp_postmeta`
--
ALTER TABLE `wp_postmeta`
  ADD PRIMARY KEY (`meta_id`),
  ADD KEY `post_id` (`post_id`),
  ADD KEY `meta_key` (`meta_key`(191));

--
-- Indexes for table `wp_posts`
--
ALTER TABLE `wp_posts`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `post_name` (`post_name`(191)),
  ADD KEY `type_status_date` (`post_type`,`post_status`,`post_date`,`ID`),
  ADD KEY `post_parent` (`post_parent`),
  ADD KEY `post_author` (`post_author`);

--
-- Indexes for table `wp_smush_dir_images`
--
ALTER TABLE `wp_smush_dir_images`
  ADD UNIQUE KEY `id` (`id`),
  ADD UNIQUE KEY `path` (`path`(191)),
  ADD KEY `image_size` (`image_size`);

--
-- Indexes for table `wp_termmeta`
--
ALTER TABLE `wp_termmeta`
  ADD PRIMARY KEY (`meta_id`),
  ADD KEY `term_id` (`term_id`),
  ADD KEY `meta_key` (`meta_key`(191));

--
-- Indexes for table `wp_terms`
--
ALTER TABLE `wp_terms`
  ADD PRIMARY KEY (`term_id`),
  ADD KEY `slug` (`slug`(191)),
  ADD KEY `name` (`name`(191));

--
-- Indexes for table `wp_term_relationships`
--
ALTER TABLE `wp_term_relationships`
  ADD PRIMARY KEY (`object_id`,`term_taxonomy_id`),
  ADD KEY `term_taxonomy_id` (`term_taxonomy_id`);

--
-- Indexes for table `wp_term_taxonomy`
--
ALTER TABLE `wp_term_taxonomy`
  ADD PRIMARY KEY (`term_taxonomy_id`),
  ADD UNIQUE KEY `term_id_taxonomy` (`term_id`,`taxonomy`),
  ADD KEY `taxonomy` (`taxonomy`);

--
-- Indexes for table `wp_usermeta`
--
ALTER TABLE `wp_usermeta`
  ADD PRIMARY KEY (`umeta_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `meta_key` (`meta_key`(191));

--
-- Indexes for table `wp_users`
--
ALTER TABLE `wp_users`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `user_login_key` (`user_login`),
  ADD KEY `user_nicename` (`user_nicename`),
  ADD KEY `user_email` (`user_email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `wp_commentmeta`
--
ALTER TABLE `wp_commentmeta`
  MODIFY `meta_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `wp_comments`
--
ALTER TABLE `wp_comments`
  MODIFY `comment_ID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `wp_links`
--
ALTER TABLE `wp_links`
  MODIFY `link_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `wp_ngg_album`
--
ALTER TABLE `wp_ngg_album`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `wp_ngg_gallery`
--
ALTER TABLE `wp_ngg_gallery`
  MODIFY `gid` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `wp_ngg_pictures`
--
ALTER TABLE `wp_ngg_pictures`
  MODIFY `pid` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `wp_options`
--
ALTER TABLE `wp_options`
  MODIFY `option_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=426;
--
-- AUTO_INCREMENT for table `wp_postmeta`
--
ALTER TABLE `wp_postmeta`
  MODIFY `meta_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=175;
--
-- AUTO_INCREMENT for table `wp_posts`
--
ALTER TABLE `wp_posts`
  MODIFY `ID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;
--
-- AUTO_INCREMENT for table `wp_smush_dir_images`
--
ALTER TABLE `wp_smush_dir_images`
  MODIFY `id` mediumint(9) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `wp_termmeta`
--
ALTER TABLE `wp_termmeta`
  MODIFY `meta_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `wp_terms`
--
ALTER TABLE `wp_terms`
  MODIFY `term_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `wp_term_taxonomy`
--
ALTER TABLE `wp_term_taxonomy`
  MODIFY `term_taxonomy_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `wp_usermeta`
--
ALTER TABLE `wp_usermeta`
  MODIFY `umeta_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT for table `wp_users`
--
ALTER TABLE `wp_users`
  MODIFY `ID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
