/* appearance */
static const unsigned int borderpx  = 0;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 0;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "Inconsolata:pixelsize=26:antialias=true:autohint=true" };
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#005577";
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            1,           -1 },
	{ "Firefox",  NULL,       NULL,       1 << 8,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int refreshrate = 120;  /* refresh rate (per second) for client move/resize */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[]  = { "st", NULL };
static const char *browsercmd[]  = { "brave", NULL };
static const char *thunarcmd[] = { "thunar", NULL };

static const Key keys[] = {
	/* modifier                     key        function        argument */
    /* volume */
    { 0, XF86XK_AudioRaiseVolume, spawn, SHCMD("pamixer -i 5") },
    { 0, XF86XK_AudioLowerVolume, spawn, SHCMD("pamixer -d 5") },
    { 0, XF86XK_AudioMute,        spawn, SHCMD("pamixer -t") },

    /* brightness */
    { 0, XF86XK_MonBrightnessUp,   spawn, SHCMD("brightnessctl set +5%") },
    { 0, XF86XK_MonBrightnessDown, spawn, SHCMD("brightnessctl set 5%-") },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_w,      spawn,          {.v = browsercmd } },
    { MODKEY,                       XK_e,      spawn,          {.v = thunarcmd } },
    { MODKEY,                       XK_u,      focusstack,     { .i = -1 } },
    { MODKEY,                       XK_o,      focusstack,     { .i = +1 } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_i,      killclient,     {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
    { MODKEY,                       XK_space,  togglefloating, {0} },


    { MODKEY, XK_j, view, {.ui = 1 << 0} },
    { MODKEY|ShiftMask, XK_j, tagandview, {.ui = 1 << 0} },

    { MODKEY, XK_k, view, {.ui = 1 << 1} },
    { MODKEY|ShiftMask, XK_k, tagandview, {.ui = 1 << 1} },

    { MODKEY, XK_l, view, {.ui = 1 << 2} },
    { MODKEY|ShiftMask, XK_l, tagandview, {.ui = 1 << 2} },

    { MODKEY, XK_odiaeresis, view, {.ui = 1 << 3} },
    { MODKEY|ShiftMask, XK_odiaeresis, tagandview, {.ui = 1 << 3} },

    { MODKEY, XK_m, view, {.ui = 1 << 4} },
    { MODKEY|ShiftMask, XK_m, tagandview, {.ui = 1 << 4} },

    { MODKEY, XK_comma, view, {.ui = 1 << 5} },
    { MODKEY|ShiftMask, XK_comma, tagandview, {.ui = 1 << 5} },

    { MODKEY, XK_period, view, {.ui = 1 << 6} },
    { MODKEY|ShiftMask, XK_period, tagandview, {.ui = 1 << 6} },

    { MODKEY, XK_minus, view, {.ui = 1 << 7} },
    { MODKEY|ShiftMask, XK_minus, tagandview, {.ui = 1 << 7} },
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
