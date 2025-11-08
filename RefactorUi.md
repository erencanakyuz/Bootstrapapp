Aşağıya bu tasarımın stilini oldukça ayrıntılı bir JSON tasarım sistemi olarak yazdım.
Bunu direkt olarak başka bir yapay zekâya verip Flutter widget’ları üretmesi için kullanabilirsin.

Not: Ölçüler ve bazı renkler piksel/palet tahmini; ama görünüm olarak ekrandaki stile çok çok yakın durur.

{
  "meta": {
    "name": "FutureStyleUI",
    "description": "Soft beige background, warm pastel gradients and editorial typography inspired mobile journaling app.",
    "platform": "flutter",
    "baseDevice": {
      "referenceDevice": "iPhone 14 Pro",
      "logicalWidth": 393,
      "logicalHeight": 852,
      "safeArea": {
        "top": 59,
        "bottom": 34,
        "left": 0,
        "right": 0
      }
    }
  },
  "tokens": {
    "colors": {
      "brandBackground": "#E7DCD1",
      "brandTextPrimary": "#292624",
      "brandTextSecondary": "#6D6256",
      "brandAccentPurple": "#A371F2",
      "brandAccentPurpleSoft": "#C39BF8",
      "brandAccentPeach": "#F8C9A2",
      "brandAccentPeachSoft": "#FDE5C9",
      "brandCardBackground": "#FFFFFF",
      "brandSurfaceAlt": "#FFFCF8",
      "brandBorderSubtle": "#EFE4D9",
      "brandMutedIcon": "#B7A89A",
      "danger": "#E15A5A",
      "success": "#4BAE88",
      "info": "#5F8BE5",
      "shadowSoft": "rgba(0,0,0,0.07)",
      "shadowStrong": "rgba(0,0,0,0.12)",
      "scrim": "rgba(20,10,0,0.35)",
      "audioWavePrimary": "#A371F2",
      "audioWaveSecondary": "#E1D2FF",
      "gradientPeachHorizontalStart": "#F8C9A2",
      "gradientPeachHorizontalEnd": "#FDE5C9",
      "gradientPurpleVerticalStart": "#A371F2",
      "gradientPurpleVerticalEnd": "#D9B5FF",
      "gradientPurpleLighterStart": "#E5D4FF",
      "gradientPurpleLighterEnd": "#F8ECFF",
      "gradientBlueAudioStart": "#CBDCFF",
      "gradientBlueAudioEnd": "#F2F6FF",
      "badgeNewBackground": "#292624",
      "badgeNewText": "#FFFFFF",
      "chipOutline": "#D7C9BA",
      "chipText": "#5F5245",
      "inputBackground": "#FFFFFF",
      "inputBorder": "#E5D8CA",
      "inputPlaceholder": "#B3A59A",
      "toggleOffTrack": "#E5D8CA",
      "toggleOffThumb": "#FFFFFF",
      "toggleOnTrack": "#A371F2",
      "toggleOnThumb": "#FFFFFF",
      "navIconActive": "#292624",
      "navIconInactive": "#B3A59A",
      "navLabelInactive": "#867A6D",
      "navPillBackground": "#FFFFFF",
      "socialLikeBadgeGradientStart": "#FAD0FF",
      "socialLikeBadgeGradientEnd": "#FAD0B2",
      "socialIllustrationEyeIris": "#A371F2",
      "socialIllustrationSkin": "#F5A48A"
    },
    "radii": {
      "xs": 4,
      "sm": 8,
      "md": 12,
      "lg": 16,
      "xl": 24,
      "xxl": 32,
      "pill": 999
    },
    "spacing": {
      "xxs": 4,
      "xs": 8,
      "sm": 12,
      "md": 16,
      "lg": 20,
      "xl": 24,
      "xxl": 32,
      "3xl": 40
    },
    "elevation": {
      "cardSoft": {
        "blurRadius": 24,
        "spreadRadius": 0,
        "offsetX": 0,
        "offsetY": 10,
        "color": "shadowSoft"
      },
      "cardStrong": {
        "blurRadius": 32,
        "spreadRadius": 0,
        "offsetX": 0,
        "offsetY": 18,
        "color": "shadowStrong"
      },
      "floatingButton": {
        "blurRadius": 32,
        "offsetX": 0,
        "offsetY": 12,
        "spreadRadius": 0,
        "color": "shadowStrong"
      }
    },
    "typography": {
      "fontFamilies": {
        "serifDisplay": "Fraunces",
        "sansBody": "SF Pro Text",
        "sansUI": "SF Pro Rounded"
      },
      "styles": {
        "displayHero": {
          "fontFamily": "serifDisplay",
          "fontSize": 34,
          "fontWeight": 700,
          "letterSpacing": -0.6,
          "lineHeight": 1.1,
          "color": "brandTextPrimary"
        },
        "displayLarge": {
          "fontFamily": "serifDisplay",
          "fontSize": 28,
          "fontWeight": 700,
          "letterSpacing": -0.4,
          "lineHeight": 1.15,
          "color": "brandTextPrimary"
        },
        "titlePage": {
          "fontFamily": "serifDisplay",
          "fontSize": 22,
          "fontWeight": 600,
          "letterSpacing": -0.2,
          "lineHeight": 1.2,
          "color": "brandTextPrimary"
        },
        "titleSection": {
          "fontFamily": "serifDisplay",
          "fontSize": 20,
          "fontWeight": 600,
          "letterSpacing": -0.1,
          "lineHeight": 1.2,
          "color": "brandTextPrimary"
        },
        "titleCard": {
          "fontFamily": "serifDisplay",
          "fontSize": 18,
          "fontWeight": 600,
          "letterSpacing": -0.1,
          "lineHeight": 1.25,
          "color": "brandTextPrimary"
        },
        "headlineStrongSans": {
          "fontFamily": "sansUI",
          "fontSize": 32,
          "fontWeight": 700,
          "letterSpacing": -0.5,
          "lineHeight": 1.1,
          "color": "brandTextPrimary"
        },
        "headlineEmphasisSans": {
          "fontFamily": "sansUI",
          "fontSize": 32,
          "fontWeight": 500,
          "fontStyle": "italic",
          "letterSpacing": -0.5,
          "lineHeight": 1.1,
          "color": "brandTextPrimary"
        },
        "bodyPrimary": {
          "fontFamily": "sansBody",
          "fontSize": 15,
          "fontWeight": 400,
          "letterSpacing": 0.0,
          "lineHeight": 1.4,
          "color": "brandTextSecondary"
        },
        "bodySecondary": {
          "fontFamily": "sansBody",
          "fontSize": 13,
          "fontWeight": 400,
          "letterSpacing": 0.0,
          "lineHeight": 1.4,
          "color": "brandTextSecondary"
        },
        "bodyBold": {
          "fontFamily": "sansBody",
          "fontSize": 15,
          "fontWeight": 600,
          "letterSpacing": 0.0,
          "lineHeight": 1.4,
          "color": "brandTextPrimary"
        },
        "caption": {
          "fontFamily": "sansBody",
          "fontSize": 11,
          "fontWeight": 400,
          "letterSpacing": 0.1,
          "lineHeight": 1.2,
          "color": "brandTextSecondary"
        },
        "captionUppercase": {
          "fontFamily": "sansBody",
          "fontSize": 11,
          "fontWeight": 500,
          "letterSpacing": 0.25,
          "lineHeight": 1.2,
          "textTransform": "uppercase",
          "color": "brandTextSecondary"
        },
        "buttonLabel": {
          "fontFamily": "sansUI",
          "fontSize": 15,
          "fontWeight": 600,
          "letterSpacing": 0.1,
          "lineHeight": 1.2,
          "color": "brandTextPrimary"
        },
        "buttonLabelGhost": {
          "fontFamily": "sansUI",
          "fontSize": 15,
          "fontWeight": 600,
          "letterSpacing": 0.1,
          "lineHeight": 1.2,
          "color": "brandTextSecondary"
        },
        "inputPlaceholder": {
          "fontFamily": "sansBody",
          "fontSize": 15,
          "fontWeight": 400,
          "letterSpacing": 0.0,
          "lineHeight": 1.3,
          "color": "inputPlaceholder"
        },
        "numericBadge": {
          "fontFamily": "serifDisplay",
          "fontSize": 52,
          "fontWeight": 700,
          "letterSpacing": -2.0,
          "lineHeight": 1.0,
          "color": "brandSurfaceAlt"
        }
      }
    },
    "iconography": {
      "strokeWidth": 2,
      "cornerStyle": "rounded",
      "defaultSize": 20,
      "lineCaps": "round",
      "theme": "minimal-outline",
      "illustrationLineColor": "#6D6256"
    }
  },
  "components": {
    "appScaffold": {
      "backgroundColor": "brandBackground",
      "statusBarStyle": "dark-content",
      "navigationBar": {
        "type": "transparentOverlay",
        "titleAlignment": "center",
        "titleStyle": "titlePage",
        "leadingBackButton": {
          "visible": true,
          "icon": "chevron-left",
          "size": 20,
          "tappableArea": 44
        }
      }
    },
    "bottomNav": {
      "height": 80,
      "backgroundColor": "brandBackground",
      "pill": {
        "backgroundColor": "navPillBackground",
        "cornerRadius": "pill",
        "paddingHorizontal": 24,
        "paddingVertical": 10,
        "elevation": "cardSoft"
      },
      "item": {
        "iconSize": 22,
        "spacing": 4,
        "labelStyleActive": {
          "inherits": "caption",
          "color": "navIconActive"
        },
        "labelStyleInactive": {
          "inherits": "caption",
          "color": "navLabelInactive"
        }
      }
    },
    "primaryButton": {
      "height": 52,
      "borderRadius": "pill",
      "backgroundColor": "brandTextPrimary",
      "textStyle": "buttonLabel",
      "horizontalPadding": 24,
      "shadow": "cardSoft",
      "pressedOpacity": 0.8
    },
    "secondaryButton": {
      "height": 52,
      "borderRadius": "pill",
      "backgroundColor": "inputBackground",
      "borderColor": "brandBorderSubtle",
      "borderWidth": 1,
      "textStyle": "buttonLabelGhost",
      "horizontalPadding": 24,
      "shadow": null
    },
    "iconButtonGhost": {
      "size": 40,
      "backgroundColor": "transparent",
      "iconColor": "brandTextPrimary",
      "shape": "circle"
    },
    "pillChip": {
      "height": 30,
      "paddingHorizontal": 14,
      "borderRadius": "pill",
      "borderColor": "chipOutline",
      "borderWidth": 1,
      "backgroundColor": "navPillBackground",
      "labelStyle": "captionUppercase",
      "iconSize": 12,
      "spacing": 6
    },
    "toggleCheckbox": {
      "size": 24,
      "borderRadius": 8,
      "borderWidth": 1.5,
      "borderColorOff": "chipOutline",
      "borderColorOn": "brandAccentPurple",
      "fillColorOn": "brandAccentPurple",
      "checkIconColor": "#FFFFFF"
    },
    "cardJournalPreview": {
      "size": {
        "widthRatioToScreen": 0.72,
        "height": 210
      },
      "borderRadius": "xl",
      "padding": {
        "top": 18,
        "left": 18,
        "right": 18,
        "bottom": 18
      },
      "backgroundGradient": {
        "type": "linear",
        "direction": "left-to-right",
        "colors": [
          "gradientPeachHorizontalStart",
          "gradientPeachHorizontalEnd"
        ]
      },
      "elevation": "cardSoft",
      "overlayLargeNumber": {
        "textStyle": "numericBadge",
        "alignment": "top-left",
        "opacity": 0.25,
        "offsetX": -4,
        "offsetY": -8
      },
      "badgeNew": {
        "backgroundColor": "badgeNewBackground",
        "textColor": "badgeNewText",
        "cornerRadius": 999,
        "paddingHorizontal": 10,
        "paddingVertical": 4,
        "textStyle": "captionUppercase",
        "position": "top-left"
      },
      "title": {
        "textStyle": "titleCard",
        "maxLines": 1
      },
      "body": {
        "textStyle": "bodySecondary",
        "maxLines": 3
      },
      "metaRow": {
        "dateStyle": "caption",
        "iconSize": 12
      }
    },
    "cardJournalPreviewSecondary": {
      "inherits": "cardJournalPreview",
      "backgroundGradient": {
        "type": "linear",
        "direction": "left-to-right",
        "colors": [
          "gradientPurpleLighterStart",
          "gradientPurpleLighterEnd"
        ]
      },
      "badgeNew": {
        "enabled": false
      }
    },
    "cardHorizontalCTA": {
      "height": 80,
      "borderRadius": "lg",
      "paddingHorizontal": 18,
      "paddingVertical": 14,
      "backgroundGradient": {
        "type": "linear",
        "direction": "left-to-right",
        "colors": [
          "gradientPurpleLighterStart",
          "gradientPeachHorizontalEnd"
        ]
      },
      "titleStyle": "bodyBold",
      "subtitleStyle": "caption",
      "actionLabelStyle": "captionUppercase",
      "icon": {
        "size": 16,
        "alignedRight": true
      }
    },
    "audioPlayerCard": {
      "borderRadius": "xl",
      "backgroundGradient": {
        "type": "radial",
        "colors": [
          "gradientBlueAudioStart",
          "gradientBlueAudioEnd"
        ],
        "center": {
          "x": 0.5,
          "y": 0.3
        }
      },
      "padding": {
        "top": 26,
        "left": 24,
        "right": 24,
        "bottom": 26
      },
      "elevation": "cardSoft",
      "titleStyle": "titlePage",
      "subtitleStyle": "caption",
      "waveform": {
        "height": 48,
        "barWidth": 3,
        "barGap": 2,
        "colorPrimary": "audioWavePrimary",
        "colorSecondary": "audioWaveSecondary",
        "cornerRadius": 2
      },
      "controls": {
        "playButtonSize": 48,
        "playButtonIconSize": 20,
        "playButtonBackground": "brandTextPrimary",
        "playButtonIconColor": "#FFFFFF",
        "scrubberTrackColor": "#E1D2FF",
        "scrubberThumbRadius": 6,
        "timeStyle": "caption"
      }
    },
    "inputTextLarge": {
      "height": 52,
      "borderRadius": "lg",
      "backgroundColor": "inputBackground",
      "borderColor": "inputBorder",
      "borderWidth": 1,
      "paddingHorizontal": 16,
      "textStyle": "bodyPrimary",
      "placeholderStyle": "inputPlaceholder"
    },
    "inputMultilineLarge": {
      "minHeight": 140,
      "borderRadius": "lg",
      "backgroundColor": "inputBackground",
      "borderColor": "inputBorder",
      "borderWidth": 1,
      "paddingHorizontal": 16,
      "paddingVertical": 14,
      "textStyle": "bodyPrimary",
      "placeholderStyle": "inputPlaceholder"
    },
    "microphoneBlob": {
      "size": 140,
      "type": "radialGlow",
      "centerColor": "brandAccentPurple",
      "outerColor": "gradientPurpleLighterEnd",
      "innerOpacity": 0.7,
      "outerOpacity": 0.4,
      "embeddedIcon": {
        "glyph": "mic",
        "size": 32,
        "color": "brandTextPrimary"
      }
    },
    "stepIndicatorDots": {
      "dotSize": 6,
      "spacing": 6,
      "inactiveColor": "#D5C7B9",
      "activeColor": "brandTextPrimary",
      "position": "bottom-center"
    },
    "promiseCard": {
      "borderRadius": "lg",
      "padding": {
        "top": 16,
        "left": 16,
        "right": 16,
        "bottom": 14
      },
      "backgroundColor": "brandCardBackground",
      "borderWidth": 1,
      "borderColor": "brandBorderSubtle",
      "elevation": "cardSoft",
      "titleStyle": "bodyBold",
      "categoryLabelStyle": "captionUppercase",
      "descriptionStyle": "bodySecondary",
      "metaRowStyle": "caption",
      "checkbox": "toggleCheckbox",
      "gapBetweenElements": 6
    },
    "tagCategory": {
      "borderRadius": "pill",
      "backgroundColor": "brandSurfaceAlt",
      "paddingHorizontal": 14,
      "paddingVertical": 6,
      "textStyle": "captionUppercase"
    },
    "gradientScreenBackgroundPurple": {
      "type": "linear",
      "direction": "top-to-bottom",
      "colors": [
        "gradientPurpleLighterStart",
        "brandBackground"
      ]
    },
    "marketingHeroTextBlock": {
      "maxWidthRatio": 0.7,
      "lineSpacing": 8,
      "tokens": {
        "like": {
          "style": "headlineEmphasisSans"
        },
        "follow": {
          "style": "headlineStrongSans"
        },
        "stay": {
          "style": "headlineEmphasisSans"
        },
        "connected": {
          "style": "headlineStrongSans"
        },
        "default": {
          "style": "headlineStrongSans"
        }
      }
    },
    "marketingBadgePill": {
      "borderRadius": "pill",
      "paddingHorizontal": 16,
      "paddingVertical": 6,
      "borderWidth": 1,
      "borderColor": "brandTextPrimary",
      "labelStyle": "captionUppercase",
      "backgroundColor": "navPillBackground"
    },
    "marketingIllustrationThumb": {
      "width": 80,
      "height": 40,
      "shape": "rounded-rect",
      "borderRadius": 20,
      "fillColor": "socialIllustrationSkin",
      "detailDotsCount": 3,
      "detailDotRadius": 4,
      "detailDotColor": "brandTextPrimary"
    }
  },
  "screens": {
    "journalHome": {
      "name": "Future Moments List",
      "backgroundColor": "brandBackground",
      "layout": {
        "paddingHorizontal": "xl",
        "paddingTop": 88,
        "paddingBottom": 110,
        "sections": [
          {
            "id": "header",
            "type": "column",
            "spacing": "sm",
            "children": [
              {
                "type": "text",
                "style": "captionUppercase",
                "text": "Future Journal"
              },
              {
                "type": "text",
                "style": "titleSection",
                "text": "Future Moments"
              },
              {
                "type": "text",
                "style": "bodySecondary",
                "text": "Weekly notes to inspire your everyday journey."
              }
            ]
          },
          {
            "id": "momentCarousel",
            "type": "horizontalList",
            "itemComponent": "cardJournalPreview",
            "spacing": "md",
            "topMargin": "lg",
            "scrollSnapping": "leading-edge"
          },
          {
            "id": "upcomingSection",
            "type": "column",
            "topMargin": "xl",
            "spacing": "sm",
            "children": [
              {
                "type": "text",
                "style": "titleSection",
                "text": "Your One Perfect Day"
              },
              {
                "type": "text",
                "style": "bodySecondary",
                "text": "Update your future journal to align with your evolving dreams."
              },
              {
                "type": "card",
                "component": "cardHorizontalCTA"
              }
            ]
          }
        ]
      },
      "bottomNavigation": {
        "visible": true,
        "selectedIndex": 0
      }
    },
    "audioFutureMoment": {
      "name": "Audio Future Moment Player",
      "backgroundColor": "brandBackground",
      "layout": {
        "paddingHorizontal": "xl",
        "paddingTop": 80,
        "paddingBottom": 110,
        "sections": [
          {
            "id": "topNav",
            "type": "row",
            "mainAxisAlignment": "space-between",
            "children": [
              {
                "type": "iconButton",
                "component": "iconButtonGhost",
                "icon": "chevron-down"
              },
              {
                "type": "iconButton",
                "component": "iconButtonGhost",
                "icon": "ellipsis-horizontal"
              }
            ]
          },
          {
            "id": "coverArt",
            "type": "card",
            "component": "audioPlayerCard",
            "topMargin": "xl"
          },
          {
            "id": "transcript",
            "type": "column",
            "topMargin": "xl",
            "spacing": "xs",
            "children": [
              {
                "type": "text",
                "style": "captionUppercase",
                "text": "Alexander's Future Moment"
              },
              {
                "type": "text",
                "style": "bodyPrimary",
                "textAlign": "left",
                "text": "This week, I'm watching sunlight dance across my morning coffee..."
              }
            ]
          }
        ]
      },
      "bottomNavigation": {
        "visible": false
      }
    },
    "identityQuestionScreen": {
      "name": "Who do you choose to become",
      "backgroundColor": "brandBackground",
      "layout": {
        "paddingHorizontal": "xl",
        "paddingTop": 120,
        "paddingBottom": 120,
        "sections": [
          {
            "id": "questionText",
            "type": "column",
            "spacing": "sm",
            "children": [
              {
                "type": "text",
                "style": "caption",
                "text": "Release who you've been... Step into infinite possibility."
              },
              {
                "type": "text",
                "style": "displayLarge",
                "text": "Who do you choose to become?"
              }
            ]
          },
          {
            "id": "answerInput",
            "type": "column",
            "topMargin": "xl",
            "spacing": "md",
            "children": [
              {
                "type": "input",
                "component": "inputMultilineLarge",
                "placeholder": "Say something...",
                "helperText": "use at least 100 characters"
              },
              {
                "type": "spacer",
                "height": 40
              },
              {
                "type": "center",
                "child": {
                  "type": "custom",
                  "component": "microphoneBlob"
                }
              },
              {
                "type": "text",
                "style": "caption",
                "textAlign": "center",
                "text": "Tap to stop recording"
              }
            ]
          },
          {
            "id": "bottomButton",
            "type": "alignBottom",
            "child": {
              "type": "button",
              "component": "secondaryButton",
              "label": "Continue",
              "enabled": false
            }
          }
        ]
      }
    },
    "perfectDayIntro": {
      "name": "Your Perfect Day Intro",
      "backgroundGradient": "gradientScreenBackgroundPurple",
      "layout": {
        "paddingHorizontal": "xl",
        "paddingTop": 120,
        "paddingBottom": 120,
        "sections": [
          {
            "id": "centerContent",
            "type": "center",
            "child": {
              "type": "column",
              "spacing": "lg",
              "crossAxisAlignment": "center",
              "children": [
                {
                  "type": "text",
                  "style": "bodySecondary",
                  "textAlign": "center",
                  "text": "Let’s step into a day in the life as your future self."
                },
                {
                  "type": "text",
                  "style": "titlePage",
                  "textAlign": "center",
                  "text": "Your Perfect Day"
                },
                {
                  "type": "icon",
                  "glyph": "sun-smile",
                  "size": 40
                },
                {
                  "type": "text",
                  "style": "bodySecondary",
                  "textAlign": "center",
                  "text": "All set!"
                }
              ]
            }
          }
        ]
      }
    },
    "exploreHabits": {
      "name": "Explore & Visualization",
      "backgroundColor": "brandBackground",
      "hasBottomNav": true,
      "layout": {
        "paddingHorizontal": "xl",
        "paddingTop": 88,
        "paddingBottom": 110,
        "sections": [
          {
            "id": "topBar",
            "type": "centerTitle",
            "children": [
              {
                "type": "text",
                "style": "titlePage",
                "text": "Explore"
              }
            ]
          },
          {
            "id": "uncoverNewHabitsCTA",
            "type": "card",
            "component": "cardHorizontalCTA",
            "topMargin": "xl"
          },
          {
            "id": "visualizationExercisesTitle",
            "type": "text",
            "style": "titleSection",
            "text": "Visualization Exercises",
            "topMargin": "xl"
          },
          {
            "id": "visualizationDescription",
            "type": "text",
            "style": "bodySecondary",
            "text": "Train your mind to bridge the gap between today and your future self...",
            "topMargin": "sm"
          },
          {
            "id": "visualizationList",
            "type": "column",
            "topMargin": "md",
            "spacing": "sm",
            "children": [
              {
                "type": "card",
                "component": "cardHorizontalCTA"
              },
              {
                "type": "card",
                "component": "cardHorizontalCTA"
              }
            ]
          }
        ]
      }
    },
    "choosePromises": {
      "name": "Choose Your Promises",
      "backgroundColor": "brandBackground",
      "layout": {
        "paddingHorizontal": "xl",
        "paddingTop": 88,
        "paddingBottom": 110,
        "sections": [
          {
            "id": "header",
            "type": "column",
            "spacing": "xs",
            "children": [
              {
                "type": "text",
                "style": "titlePage",
                "text": "Choose your promises"
              },
              {
                "type": "text",
                "style": "bodySecondary",
                "text": "You can change/edit them later"
              }
            ]
          },
          {
            "id": "promiseList",
            "type": "column",
            "topMargin": "lg",
            "spacing": "md",
            "children": [
              {
                "type": "card",
                "component": "promiseCard"
              },
              {
                "type": "card",
                "component": "promiseCard"
              },
              {
                "type": "card",
                "component": "promiseCard"
              }
            ]
          },
          {
            "id": "bottomButton",
            "type": "alignBottom",
            "child": {
              "type": "button",
              "component": "primaryButton",
              "label": "Add to my habits"
            }
          }
        ]
      }
    },
    "socialBanner": {
      "name": "Marketing Social Banner",
      "backgroundColor": "brandBackground",
      "layout": {
        "paddingHorizontal": "3xl",
        "paddingVertical": "3xl",
        "sections": [
          {
            "id": "topBadges",
            "type": "row",
            "spacing": "sm",
            "children": [
              {
                "type": "badge",
                "component": "marketingBadgePill",
                "label": "DEVELOPMENT"
              },
              {
                "type": "badge",
                "component": "marketingBadgePill",
                "label": "UI/UX DESIGN"
              },
              {
                "type": "badge",
                "component": "marketingBadgePill",
                "label": "BRANDING"
              }
            ]
          },
          {
            "id": "heroRow",
            "type": "row",
            "topMargin": "xxl",
            "mainAxisAlignment": "spaceBetween",
            "children": [
              {
                "type": "custom",
                "component": "marketingHeroTextBlock",
                "text": "Drop a like and follow us to stay connected."
              },
              {
                "type": "column",
                "crossAxisAlignment": "center",
                "spacing": "lg",
                "children": [
                  {
                    "type": "shape",
                    "shapeType": "badge",
                    "size": 96,
                    "borderRadius": 48,
                    "gradient": {
                      "type": "radial",
                      "colors": [
                        "socialLikeBadgeGradientStart",
                        "socialLikeBadgeGradientEnd"
                      ]
                    },
                    "centerIcon": {
                      "glyph": "heart-fill",
                      "size": 40,
                      "color": "#FFFFFF"
                    }
                  }
                ]
              }
            ]
          },
          {
            "id": "bottomIllustrations",
            "type": "row",
            "topMargin": "3xl",
            "mainAxisAlignment": "spaceBetween",
            "children": [
              {
                "type": "row",
                "spacing": "sm",
                "children": [
                  {
                    "type": "icon",
                    "glyph": "eye-illustration",
                    "size": 42
                  },
                  {
                    "type": "icon",
                    "glyph": "eye-illustration",
                    "size": 42
                  }
                ]
              },
              {
                "type": "custom",
                "component": "marketingIllustrationThumb"
              },
              {
                "type": "icon",
                "glyph": "arrow-blob",
                "size": 48
              }
            ]
          }
        ]
      }
    }
  }
}


Bu JSON’u:

tasarım token’ları (renk, tipografi, spacing, radius),

tekrar kullanılabilir Flutter bileşenleri

ve her ekranın layout şemasını

oldukça ayrıntılı biçimde tanımlayacak şekilde kurdum.
Şimdi bunu başka bir modele “Bu JSON’daki tasarım sistemine göre Flutter UI üret” diyerek kullanabilirsin.