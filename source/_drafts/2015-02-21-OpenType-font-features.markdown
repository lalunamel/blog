---
layout: post
title: "OpenType font features"
date: 2015-02-21 18:09:02
tags: [Typography]
excerpt: ""
---
<style>
	.enabled {
		-webkit-font-feature-settings: "frac" 1;
/*		-webkit-font-feature-settings: "frac", 'liga', 'ordn', 'sups', 'pnum', 'tnum' 1;
		-moz-font-feature-settings: "frac", 'liga', 'ordn', 'sups', 'pnum', 'tnum' 1;
		-o-font-feature-settings: "frac", 'liga', 'ordn', 'sups', 'pnum', 'tnum' 1;
		font-feature-settings: "frac", 'liga', 'ordn', 'sups', 'pnum', 'tnum' 1;  */
	}

	.frac {
		-webkit-font-feature-settings: "frac" 1;
		-moz-font-feature-settings: "frac" 1;
		-o-font-feature-settings: "frac" 1;
		font-feature-settings: "frac" 1;
	}
	.liga {
		-webkit-font-feature-settings: "liga" 1;
		-moz-font-feature-settings: "liga" 1;
		-o-font-feature-settings: "liga" 1;
		font-feature-settings: "liga" 1;
	}
	.ordn {
		-webkit-font-feature-settings: "ordn" 1;
		-moz-font-feature-settings: "ordn" 1;
		-o-font-feature-settings: "ordn" 1;
		font-feature-settings: "ordn" 1;
	}
	.sups {
		-webkit-font-feature-settings: "sups" 1;
		-moz-font-feature-settings: "sups" 1;
		-o-font-feature-settings: "sups" 1;
		font-feature-settings: "sups" 1;
	}
	.pnum {
		-webkit-font-feature-settings: "pnum" 1;
		-moz-font-feature-settings: "pnum" 1;
		-o-font-feature-settings: "pnum" 1;
		font-feature-settings: "pnum" 1;
	}
	.tnum {
		-webkit-font-feature-settings: "tnum" 1;
		-moz-font-feature-settings: "tnum" 1;
		-o-font-feature-settings: "tnum" 1;
		font-feature-settings: "tnum" 1;
	}
</style>

I recently finished reading through the [WC3's CSS Fonts Module Level 3](http://www.w3.org/TR/css3-fonts) document[^1] and found out that OpenType supports some features that would make typographers giggle with glee.

So I took a look the font used throughout this site, Futura-PT from Typekit, and noticed it supports 6 OpenType features.

Let's demonstrate!

**frac** makes diagonal fractions  
<span class="frac">1/3</span> vs 1/3

**liga** makes ligatures  
<span class="liga">ffi</span> vs ffi

**ordn** adds ordinals (those little superscript numbers)  
<span class="ordn">1st, 2nd, 3rd</span> vs 1st, 2nd, 3rd

**sups** enables superscripts  
<span class="sups">1</span> vs 1

**pnum** essentially just kerns numbers nicely  
<span class="pnum">123456</span> vs 123456

**tnum** the opposite of _pnum_ - makes numbers monospaced  
<span class="tnum">123456</span> vs 123456


[^1]: Why would anyone read such a torturously detailed document, you ask? While working on [delicious](http://delicious.codysehl.net), my upcoming personal recipe website (and attempt to learn [Angular](http://angularjs.org)), I came up against a few fairly detailed, fairly specific questions related to text rendering in the browser.