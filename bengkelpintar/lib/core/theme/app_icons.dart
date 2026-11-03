import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Centralized Material Symbols used by the application.
///
/// The default Symbols value is Outlined; rounded variants are exposed where
/// the interface calls for Material Symbols Rounded.
abstract final class AppIcons {
  static const add = Symbols.add;
  static const addRounded = Symbols.add_rounded;
  static const album = Symbols.album;
  static const albumRounded = Symbols.album_rounded;
  static const analytics = Symbols.bar_chart;
  static const analyticsRounded = Symbols.bar_chart_rounded;
  static const apps = Symbols.apps;
  static const appsRounded = Symbols.apps_rounded;
  static const arrowBack = Symbols.arrow_back;
  static const arrowForward = Symbols.arrow_forward;
  static const barChart = Symbols.bar_chart;
  static const barChartRounded = Symbols.bar_chart_rounded;
  static const batteryFull = Symbols.battery_full;
  static const bolt = Symbols.bolt;
  static const build = Symbols.build;
  static const buildCircle = Symbols.build_circle;
  static const buildCircleRounded = Symbols.build_circle_rounded;
  static const calendarToday = Symbols.calendar_today;
  static const category = Symbols.category;
  static const check = Symbols.check;
  static const checkCircle = Symbols.check_circle;
  static const chevronRight = Symbols.chevron_right;
  static const construction = Symbols.construction;
  static const database = Symbols.database;
  static const delete = Symbols.delete;
  static const description = Symbols.description;
  static const dns = Symbols.dns;
  static const edit = Symbols.edit;
  static const editDocument = Symbols.edit_document;
  static const error = Symbols.error;
  static const errorRounded = Symbols.error_rounded;
  static const factCheck = Symbols.fact_check;
  static const factCheckRounded = Symbols.fact_check_rounded;
  static const filterAlt = Symbols.filter_alt;
  static const flare = Symbols.flare;
  static const group = Symbols.group;
  static const handyman = Symbols.handyman;
  static const handymanRounded = Symbols.handyman_rounded;
  static const history = Symbols.history;
  static const home = Symbols.home;
  static const inbox = Symbols.inbox;
  static const info = Symbols.info;
  static const infoRounded = Symbols.info_rounded;
  static const inventory = Symbols.inventory_2;
  static const keyboardArrowDown = Symbols.keyboard_arrow_down;
  static const keyboardArrowDownRounded = Symbols.keyboard_arrow_down_rounded;
  static const lock = Symbols.lock;
  static const lockReset = Symbols.lock_reset;
  static const logout = Symbols.logout;
  static const notifications = Symbols.notifications;
  static const notificationsNone = Symbols.notifications;
  static const notificationsRounded = Symbols.notifications_rounded;
  static const person = Symbols.person;
  static const profile = Symbols.account_circle;
  static const receiptLong = Symbols.receipt_long;
  static const refresh = Symbols.refresh;
  static const remove = Symbols.remove;
  static const search = Symbols.search;
  static const searchOff = Symbols.search_off;
  static const settings = Symbols.settings;
  static const share = Symbols.share;
  static const shoppingCart = Symbols.shopping_cart;
  static const storefront = Symbols.storefront;
  static const stethoscope = Symbols.stethoscope;
  static const tune = Symbols.tune;
  static const visibility = Symbols.visibility;
  static const visibilityOff = Symbols.visibility_off;
  static const waterDrop = Symbols.water_drop;
  static const wifi = Symbols.wifi;
  static const wifiOff = Symbols.wifi_off;
  static const twoWheeler = Symbols.two_wheeler;

  static const roundedAlbum = Symbols.album_rounded;
  static const roundedAdd = Symbols.add_rounded;
  static const roundedArrowBack = Symbols.arrow_back_rounded;
  static const roundedArrowForward = Symbols.arrow_forward_rounded;
  static const roundedBuild = Symbols.build_rounded;
  static const roundedBuildCircle = Symbols.build_circle_rounded;
  static const roundedCheck = Symbols.check_rounded;
  static const roundedCheckCircle = Symbols.check_circle_rounded;
  static const roundedChevronRight = Symbols.chevron_right_rounded;
  static const roundedDelete = Symbols.delete_rounded;
  static const roundedDescription = Symbols.description_rounded;
  static const roundedDns = Symbols.dns_rounded;
  static const roundedEdit = Symbols.edit_rounded;
  static const roundedError = Symbols.error_rounded;
  static const roundedFactCheck = Symbols.fact_check_rounded;
  static const roundedFilterAlt = Symbols.filter_alt_rounded;
  static const roundedElectricBolt = Symbols.electric_bolt_rounded;
  static const roundedHandyman = Symbols.handyman_rounded;
  static const roundedHome = Symbols.home_rounded;
  static const roundedInventory = Symbols.inventory_2_rounded;
  static const roundedLock = Symbols.lock_rounded;
  static const roundedLogout = Symbols.logout_rounded;
  static const roundedNotifications = Symbols.notifications_rounded;
  static const roundedInfo = Symbols.info_rounded;
  static const roundedPerson = Symbols.person_rounded;
  static const roundedProfile = Symbols.account_circle_rounded;
  static const roundedReceiptLong = Symbols.receipt_long_rounded;
  static const roundedSearch = Symbols.search_rounded;
  static const roundedSettings = Symbols.settings_rounded;
  static const roundedShare = Symbols.share_rounded;
  static const roundedShoppingCart = Symbols.shopping_cart_rounded;
  static const roundedStorefront = Symbols.storefront_rounded;
  static const roundedStethoscope = Symbols.stethoscope_rounded;
  static const roundedTune = Symbols.tune_rounded;
  static const roundedTwoWheeler = Symbols.two_wheeler_rounded;
  static const roundedVisibility = Symbols.visibility_rounded;
  static const roundedVisibilityOff = Symbols.visibility_off_rounded;
  static const roundedWaterDrop = Symbols.water_drop_rounded;
  static const roundedWifiOff = Symbols.wifi_off_rounded;
  static const roundedBolt = Symbols.bolt_rounded;
  static const roundedCircle = Symbols.circle_rounded;
  static const roundedInbox = Symbols.inbox_rounded;
  static const roundedRemove = Symbols.remove_rounded;
  static const roundedRefresh = Symbols.refresh_rounded;

  static Icon icon(
    IconData data, {
    double? size,
    Color? color,
    String? semanticLabel,
  }) => Icon(data, size: size, color: color, semanticLabel: semanticLabel);
}
