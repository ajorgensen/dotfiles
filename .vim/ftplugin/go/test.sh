


<!DOCTYPE html>
<html>
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# githubog: http://ogp.me/ns/fb/githubog#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>vim-golang/ftplugin/go/test.sh at master · jnwhiteh/vim-golang · GitHub</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png" />
    <link rel="logo" type="image/svg" href="https://github-media-downloads.s3.amazonaws.com/github-logo.svg" />
    <meta property="og:image" content="https://github.global.ssl.fastly.net/images/modules/logos_page/Octocat.png">
    <meta name="hostname" content="github-fe115-cp1-prd.iad.github.net">
    <meta name="ruby" content="ruby 1.9.3p194-tcs-github-tcmalloc (2012-05-25, TCS patched 2012-05-27, GitHub v1.0.36) [x86_64-linux]">
    <link rel="assets" href="https://github.global.ssl.fastly.net/">
    <link rel="xhr-socket" href="/_sockets" />
    
    


    <meta name="msapplication-TileImage" content="/windows-tile.png" />
    <meta name="msapplication-TileColor" content="#ffffff" />
    <meta name="selected-link" value="repo_source" data-pjax-transient />
    <meta content="collector.githubapp.com" name="octolytics-host" /><meta content="github" name="octolytics-app-id" /><meta content="4ad9948d-6f65-4f82-acc8-6d395b285fbc" name="octolytics-dimension-request_id" />
    

    
    
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />

    <meta content="authenticity_token" name="csrf-param" />
<meta content="JZTLeObdOXQ38/iBxnxWmJoEwfhUopB8AQzOCuvpNW8=" name="csrf-token" />

    <link href="https://github.global.ssl.fastly.net/assets/github-8d13b140cf7e2873c4dd1e0f589136f0e71bd381.css" media="all" rel="stylesheet" type="text/css" />
    <link href="https://github.global.ssl.fastly.net/assets/github2-d75c750a6b14571dc070b6570d9224acd7b6795e.css" media="all" rel="stylesheet" type="text/css" />
    


      <script src="https://github.global.ssl.fastly.net/assets/frameworks-f86a2975a82dceee28e5afe598d1ebbfd7109d79.js" type="text/javascript"></script>
      <script src="https://github.global.ssl.fastly.net/assets/github-8bc497b5a25db3bbde9d9735f49063fd1b82fedf.js" type="text/javascript"></script>
      
      <meta http-equiv="x-pjax-version" content="9e591fe846fcd7a162a579c1264e8ab9">

        <link data-pjax-transient rel='permalink' href='/jnwhiteh/vim-golang/blob/e4f4d6ded00b498e517939f9b01c828ec44de110/ftplugin/go/test.sh'>
  <meta property="og:title" content="vim-golang"/>
  <meta property="og:type" content="githubog:gitrepository"/>
  <meta property="og:url" content="https://github.com/jnwhiteh/vim-golang"/>
  <meta property="og:image" content="https://github.global.ssl.fastly.net/images/gravatars/gravatar-user-420.png"/>
  <meta property="og:site_name" content="GitHub"/>
  <meta property="og:description" content="vim-golang - Github mirror of Go vimscripts, synced with main repository"/>

  <meta name="description" content="vim-golang - Github mirror of Go vimscripts, synced with main repository" />

  <meta content="2118" name="octolytics-dimension-user_id" /><meta content="jnwhiteh" name="octolytics-dimension-user_login" /><meta content="1024907" name="octolytics-dimension-repository_id" /><meta content="jnwhiteh/vim-golang" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="false" name="octolytics-dimension-repository_is_fork" /><meta content="1024907" name="octolytics-dimension-repository_network_root_id" /><meta content="jnwhiteh/vim-golang" name="octolytics-dimension-repository_network_root_nwo" />
  <link href="https://github.com/jnwhiteh/vim-golang/commits/master.atom" rel="alternate" title="Recent Commits to vim-golang:master" type="application/atom+xml" />

  </head>


  <body class="logged_out  env-production  vis-public page-blob">
    <div class="wrapper">
      
      
      


      
      <div class="header header-logged-out">
  <div class="container clearfix">

    <a class="header-logo-wordmark" href="https://github.com/">
      <span class="mega-octicon octicon-logo-github"></span>
    </a>

    <div class="header-actions">
        <a class="button primary" href="/signup">Sign up</a>
      <a class="button" href="/login?return_to=%2Fjnwhiteh%2Fvim-golang%2Fblob%2Fmaster%2Fftplugin%2Fgo%2Ftest.sh">Sign in</a>
    </div>

    <div class="command-bar js-command-bar  in-repository">

      <ul class="top-nav">
          <li class="explore"><a href="/explore">Explore</a></li>
        <li class="features"><a href="/features">Features</a></li>
          <li class="enterprise"><a href="https://enterprise.github.com/">Enterprise</a></li>
          <li class="blog"><a href="/blog">Blog</a></li>
      </ul>
        <form accept-charset="UTF-8" action="/search" class="command-bar-form" id="top_search_form" method="get">

<input type="text" data-hotkey="/ s" name="q" id="js-command-bar-field" placeholder="Search or type a command" tabindex="1" autocapitalize="off"
    
    
      data-repo="jnwhiteh/vim-golang"
      data-branch="master"
      data-sha="0028cea3d7095869b4732d26dca8388bdf75cefe"
  >

    <input type="hidden" name="nwo" value="jnwhiteh/vim-golang" />

    <div class="select-menu js-menu-container js-select-menu search-context-select-menu">
      <span class="minibutton select-menu-button js-menu-target">
        <span class="js-select-button">This repository</span>
      </span>

      <div class="select-menu-modal-holder js-menu-content js-navigation-container">
        <div class="select-menu-modal">

          <div class="select-menu-item js-navigation-item js-this-repository-navigation-item selected">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" class="js-search-this-repository" name="search_target" value="repository" checked="checked" />
            <div class="select-menu-item-text js-select-button-text">This repository</div>
          </div> <!-- /.select-menu-item -->

          <div class="select-menu-item js-navigation-item js-all-repositories-navigation-item">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" name="search_target" value="global" />
            <div class="select-menu-item-text js-select-button-text">All repositories</div>
          </div> <!-- /.select-menu-item -->

        </div>
      </div>
    </div>

  <span class="octicon help tooltipped downwards" title="Show command bar help">
    <span class="octicon octicon-question"></span>
  </span>


  <input type="hidden" name="ref" value="cmdform">

</form>
    </div>

  </div>
</div>


      


          <div class="site" itemscope itemtype="http://schema.org/WebPage">
    
    <div class="pagehead repohead instapaper_ignore readability-menu">
      <div class="container">
        

<ul class="pagehead-actions">


  <li>
  <a href="/login?return_to=%2Fjnwhiteh%2Fvim-golang"
  class="minibutton with-count js-toggler-target star-button entice tooltipped upwards"
  title="You must be signed in to use this feature" rel="nofollow">
  <span class="octicon octicon-star"></span>Star
</a>
<a class="social-count js-social-count" href="/jnwhiteh/vim-golang/stargazers">
  223
</a>

  </li>

    <li>
      <a href="/login?return_to=%2Fjnwhiteh%2Fvim-golang"
        class="minibutton with-count js-toggler-target fork-button entice tooltipped upwards"
        title="You must be signed in to fork a repository" rel="nofollow">
        <span class="octicon octicon-git-branch"></span>Fork
      </a>
      <a href="/jnwhiteh/vim-golang/network" class="social-count">
        44
      </a>
    </li>
</ul>

        <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public">
          <span class="repo-label"><span>public</span></span>
          <span class="mega-octicon octicon-repo"></span>
          <span class="author">
            <a href="/jnwhiteh" class="url fn" itemprop="url" rel="author"><span itemprop="title">jnwhiteh</span></a></span
          ><span class="repohead-name-divider">/</span><strong
          ><a href="/jnwhiteh/vim-golang" class="js-current-repository js-repo-home-link">vim-golang</a></strong>

          <span class="page-context-loader">
            <img alt="Octocat-spinner-32" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
          </span>

        </h1>
      </div><!-- /.container -->
    </div><!-- /.repohead -->

    <div class="container">

      <div class="repository-with-sidebar repo-container ">

        <div class="repository-sidebar">
            

<div class="repo-nav repo-nav-full js-repository-container-pjax js-octicon-loaders">
  <div class="repo-nav-contents">
    <ul class="repo-menu">
      <li class="tooltipped leftwards" title="Code">
        <a href="/jnwhiteh/vim-golang" aria-label="Code" class="js-selected-navigation-item selected" data-gotokey="c" data-pjax="true" data-selected-links="repo_source repo_downloads repo_commits repo_tags repo_branches /jnwhiteh/vim-golang">
          <span class="octicon octicon-code"></span> <span class="full-word">Code</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

        <li class="tooltipped leftwards" title="Issues">
          <a href="/jnwhiteh/vim-golang/issues" aria-label="Issues" class="js-selected-navigation-item js-disable-pjax" data-gotokey="i" data-selected-links="repo_issues /jnwhiteh/vim-golang/issues">
            <span class="octicon octicon-issue-opened"></span> <span class="full-word">Issues</span>
            <span class='counter'>0</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>        </li>

      <li class="tooltipped leftwards" title="Pull Requests"><a href="/jnwhiteh/vim-golang/pulls" aria-label="Pull Requests" class="js-selected-navigation-item js-disable-pjax" data-gotokey="p" data-selected-links="repo_pulls /jnwhiteh/vim-golang/pulls">
            <span class="octicon octicon-git-pull-request"></span> <span class="full-word">Pull Requests</span>
            <span class='counter'>0</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>


    </ul>
    <div class="repo-menu-separator"></div>
    <ul class="repo-menu">

      <li class="tooltipped leftwards" title="Pulse">
        <a href="/jnwhiteh/vim-golang/pulse" aria-label="Pulse" class="js-selected-navigation-item " data-pjax="true" data-selected-links="pulse /jnwhiteh/vim-golang/pulse">
          <span class="octicon octicon-pulse"></span> <span class="full-word">Pulse</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped leftwards" title="Graphs">
        <a href="/jnwhiteh/vim-golang/graphs" aria-label="Graphs" class="js-selected-navigation-item " data-pjax="true" data-selected-links="repo_graphs repo_contributors /jnwhiteh/vim-golang/graphs">
          <span class="octicon octicon-graph"></span> <span class="full-word">Graphs</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped leftwards" title="Network">
        <a href="/jnwhiteh/vim-golang/network" aria-label="Network" class="js-selected-navigation-item js-disable-pjax" data-selected-links="repo_network /jnwhiteh/vim-golang/network">
          <span class="octicon octicon-git-branch"></span> <span class="full-word">Network</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>
    </ul>


  </div>
</div>

            <div class="only-with-full-nav">
              

  

<div class="clone-url open"
  data-protocol-type="http"
  data-url="/users/set_protocol?protocol_selector=http&amp;protocol_type=clone">
  <h3><strong>HTTPS</strong> clone URL</h3>

  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/jnwhiteh/vim-golang.git" readonly="readonly">

    <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="https://github.com/jnwhiteh/vim-golang.git" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>

  

<div class="clone-url "
  data-protocol-type="subversion"
  data-url="/users/set_protocol?protocol_selector=subversion&amp;protocol_type=clone">
  <h3><strong>Subversion</strong> checkout URL</h3>

  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/jnwhiteh/vim-golang" readonly="readonly">

    <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="https://github.com/jnwhiteh/vim-golang" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>



<p class="clone-options">You can clone with
    <a href="#" class="js-clone-selector" data-protocol="http">HTTPS</a>,
    <a href="#" class="js-clone-selector" data-protocol="subversion">Subversion</a>,
  and <a href="https://help.github.com/articles/which-remote-url-should-i-use">other methods.</a>
</p>



                <a href="/jnwhiteh/vim-golang/archive/master.zip"
                   class="minibutton sidebar-button"
                   title="Download this repository as a zip file"
                   rel="nofollow">
                  <span class="octicon octicon-cloud-download"></span>
                  Download ZIP
                </a>
            </div>
        </div><!-- /.repository-sidebar -->

        <div id="js-repo-pjax-container" class="repository-content context-loader-container" data-pjax-container>
          


<!-- blob contrib key: blob_contributors:v21:81157636857ad99824a8ff2ffc783999 -->
<!-- blob contrib frag key: views10/v8/blob_contributors:v21:81157636857ad99824a8ff2ffc783999 -->

<p title="This is a placeholder element" class="js-history-link-replace hidden"></p>

<a href="/jnwhiteh/vim-golang/find/master" data-pjax data-hotkey="t" style="display:none">Show File Finder</a>

<div class="file-navigation">
  


<div class="select-menu js-menu-container js-select-menu" >
  <span class="minibutton select-menu-button js-menu-target" data-hotkey="w"
    data-master-branch="master"
    data-ref="master"
    role="button" aria-label="Switch branches or tags" tabindex="0">
    <span class="octicon octicon-git-branch"></span>
    <i>branch:</i>
    <span class="js-select-button">master</span>
  </span>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax>

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <span class="select-menu-title">Switch branches/tags</span>
        <span class="octicon octicon-remove-close js-menu-close"></span>
      </div> <!-- /.select-menu-header -->

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Filter branches/tags" id="context-commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" class="js-select-menu-tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" class="js-select-menu-tab">Tags</a>
            </li>
          </ul>
        </div><!-- /.select-menu-tabs -->
      </div><!-- /.select-menu-filters -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item selected">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/jnwhiteh/vim-golang/blob/master/ftplugin/go/test.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="master" data-skip-pjax="true" rel="nofollow" title="master">master</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/jnwhiteh/vim-golang/blob/syntax/ftplugin/go/test.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="syntax" data-skip-pjax="true" rel="nofollow" title="syntax">syntax</a>
            </div> <!-- /.select-menu-item -->
        </div>

          <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

    </div> <!-- /.select-menu-modal -->
  </div> <!-- /.select-menu-modal-holder -->
</div> <!-- /.select-menu -->

  <div class="breadcrumb">
    <span class='repo-root js-repo-root'><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/jnwhiteh/vim-golang" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">vim-golang</span></a></span></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/jnwhiteh/vim-golang/tree/master/ftplugin" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">ftplugin</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/jnwhiteh/vim-golang/tree/master/ftplugin/go" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">go</span></a></span><span class="separator"> / </span><strong class="final-path">test.sh</strong> <span class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="ftplugin/go/test.sh" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>


  
  <div class="commit file-history-tease">
    <img class="main-avatar" height="24" src="https://2.gravatar.com/avatar/7c82382ae3c90e2c74231c236834be0b?d=https%3A%2F%2Fidenticons.github.com%2Fc8045671083f48d8d09d1d2523ea8941.png&amp;s=140" width="24" />
    <span class="author"><a href="/dsymonds" rel="author">dsymonds</a></span>
    <time class="js-relative-date" datetime="2012-10-30T13:01:49-07:00" title="2012-10-30 13:01:49">October 30, 2012</time>
    <div class="commit-title">
        <a href="/jnwhiteh/vim-golang/commit/55b2a281948dfa1a0d72b5555b8058449706fe7c" class="message" data-pjax="true" title="misc/vim: fix Drop for imports after the first group.

Previously, an import block such as
	import (
        	&quot;net&quot;

                &quot;stack&quot;
        )
would not permit &quot;:Drop stack&quot; to work because we were aborting
the scan early, which is only correct when Import is in operation.

R=golang-dev, franciscossouza
CC=golang-dev
http://codereview.appspot.com/6532053">misc/vim: fix Drop for imports after the first group.</a>
    </div>

    <div class="participation">
      <p class="quickstat"><a href="#blob_contributors_box" rel="facebox"><strong>1</strong> contributor</a></p>
      
    </div>
    <div id="blob_contributors_box" style="display:none">
      <h2 class="facebox-header">Users who have contributed to this file</h2>
      <ul class="facebox-user-list">
        <li class="facebox-user-list-item">
          <img height="24" src="https://2.gravatar.com/avatar/7c82382ae3c90e2c74231c236834be0b?d=https%3A%2F%2Fidenticons.github.com%2Fc8045671083f48d8d09d1d2523ea8941.png&amp;s=140" width="24" />
          <a href="/dsymonds">dsymonds</a>
        </li>
      </ul>
    </div>
  </div>


<div id="files" class="bubble">
  <div class="file">
    <div class="meta">
      <div class="info">
        <span class="icon"><b class="octicon octicon-file-text"></b></span>
        <span class="mode" title="File Mode">executable file</span>
          <span>79 lines (64 sloc)</span>
        <span>1.633 kb</span>
      </div>
      <div class="actions">
        <div class="button-group">
              <a class="minibutton disabled js-entice" href=""
                 data-entice="You must be signed in to make or propose changes">Edit</a>
          <a href="/jnwhiteh/vim-golang/raw/master/ftplugin/go/test.sh" class="button minibutton " id="raw-url">Raw</a>
            <a href="/jnwhiteh/vim-golang/blame/master/ftplugin/go/test.sh" class="button minibutton ">Blame</a>
          <a href="/jnwhiteh/vim-golang/commits/master/ftplugin/go/test.sh" class="button minibutton " rel="nofollow">History</a>
        </div><!-- /.button-group -->
            <a class="minibutton danger empty-icon js-entice" href=""
               data-entice="You must be signed in and on a branch to make or propose changes">
            Delete
          </a>
      </div><!-- /.actions -->

    </div>
        <div class="blob-wrapper data type-shell js-blob-data">
        <table class="file-code file-diff">
          <tr class="file-code-line">
            <td class="blob-line-nums">
              <span id="L1" rel="#L1">1</span>
<span id="L2" rel="#L2">2</span>
<span id="L3" rel="#L3">3</span>
<span id="L4" rel="#L4">4</span>
<span id="L5" rel="#L5">5</span>
<span id="L6" rel="#L6">6</span>
<span id="L7" rel="#L7">7</span>
<span id="L8" rel="#L8">8</span>
<span id="L9" rel="#L9">9</span>
<span id="L10" rel="#L10">10</span>
<span id="L11" rel="#L11">11</span>
<span id="L12" rel="#L12">12</span>
<span id="L13" rel="#L13">13</span>
<span id="L14" rel="#L14">14</span>
<span id="L15" rel="#L15">15</span>
<span id="L16" rel="#L16">16</span>
<span id="L17" rel="#L17">17</span>
<span id="L18" rel="#L18">18</span>
<span id="L19" rel="#L19">19</span>
<span id="L20" rel="#L20">20</span>
<span id="L21" rel="#L21">21</span>
<span id="L22" rel="#L22">22</span>
<span id="L23" rel="#L23">23</span>
<span id="L24" rel="#L24">24</span>
<span id="L25" rel="#L25">25</span>
<span id="L26" rel="#L26">26</span>
<span id="L27" rel="#L27">27</span>
<span id="L28" rel="#L28">28</span>
<span id="L29" rel="#L29">29</span>
<span id="L30" rel="#L30">30</span>
<span id="L31" rel="#L31">31</span>
<span id="L32" rel="#L32">32</span>
<span id="L33" rel="#L33">33</span>
<span id="L34" rel="#L34">34</span>
<span id="L35" rel="#L35">35</span>
<span id="L36" rel="#L36">36</span>
<span id="L37" rel="#L37">37</span>
<span id="L38" rel="#L38">38</span>
<span id="L39" rel="#L39">39</span>
<span id="L40" rel="#L40">40</span>
<span id="L41" rel="#L41">41</span>
<span id="L42" rel="#L42">42</span>
<span id="L43" rel="#L43">43</span>
<span id="L44" rel="#L44">44</span>
<span id="L45" rel="#L45">45</span>
<span id="L46" rel="#L46">46</span>
<span id="L47" rel="#L47">47</span>
<span id="L48" rel="#L48">48</span>
<span id="L49" rel="#L49">49</span>
<span id="L50" rel="#L50">50</span>
<span id="L51" rel="#L51">51</span>
<span id="L52" rel="#L52">52</span>
<span id="L53" rel="#L53">53</span>
<span id="L54" rel="#L54">54</span>
<span id="L55" rel="#L55">55</span>
<span id="L56" rel="#L56">56</span>
<span id="L57" rel="#L57">57</span>
<span id="L58" rel="#L58">58</span>
<span id="L59" rel="#L59">59</span>
<span id="L60" rel="#L60">60</span>
<span id="L61" rel="#L61">61</span>
<span id="L62" rel="#L62">62</span>
<span id="L63" rel="#L63">63</span>
<span id="L64" rel="#L64">64</span>
<span id="L65" rel="#L65">65</span>
<span id="L66" rel="#L66">66</span>
<span id="L67" rel="#L67">67</span>
<span id="L68" rel="#L68">68</span>
<span id="L69" rel="#L69">69</span>
<span id="L70" rel="#L70">70</span>
<span id="L71" rel="#L71">71</span>
<span id="L72" rel="#L72">72</span>
<span id="L73" rel="#L73">73</span>
<span id="L74" rel="#L74">74</span>
<span id="L75" rel="#L75">75</span>
<span id="L76" rel="#L76">76</span>
<span id="L77" rel="#L77">77</span>
<span id="L78" rel="#L78">78</span>

            </td>
            <td class="blob-line-code">
                    <div class="highlight"><pre><div class='line' id='LC1'><span class="c">#!/bin/bash -e</span></div><div class='line' id='LC2'><span class="c">#</span></div><div class='line' id='LC3'><span class="c"># Copyright 2012 The Go Authors. All rights reserved.</span></div><div class='line' id='LC4'><span class="c"># Use of this source code is governed by a BSD-style</span></div><div class='line' id='LC5'><span class="c"># license that can be found in the LICENSE file.</span></div><div class='line' id='LC6'><span class="c">#</span></div><div class='line' id='LC7'><span class="c"># Tests for import.vim.</span></div><div class='line' id='LC8'><br/></div><div class='line' id='LC9'><span class="nb">cd</span> <span class="k">$(</span>dirname <span class="nv">$0</span><span class="k">)</span></div><div class='line' id='LC10'><br/></div><div class='line' id='LC11'>cat &gt; base.go <span class="s">&lt;&lt;EOF</span></div><div class='line' id='LC12'><span class="s">package test</span></div><div class='line' id='LC13'><br/></div><div class='line' id='LC14'><span class="s">import (</span></div><div class='line' id='LC15'><span class="s">	&quot;bytes&quot;</span></div><div class='line' id='LC16'><span class="s">	&quot;io&quot;</span></div><div class='line' id='LC17'><span class="s">	&quot;net&quot;</span></div><div class='line' id='LC18'><br/></div><div class='line' id='LC19'><span class="s">	&quot;mycorp/foo&quot;</span></div><div class='line' id='LC20'><span class="s">)</span></div><div class='line' id='LC21'><span class="s">EOF</span></div><div class='line' id='LC22'><br/></div><div class='line' id='LC23'><span class="nv">fail</span><span class="o">=</span>0</div><div class='line' id='LC24'><br/></div><div class='line' id='LC25'><span class="c"># usage: test_one command pattern</span></div><div class='line' id='LC26'><span class="c"># Pattern is a PCRE expression that will match across lines.</span></div><div class='line' id='LC27'>test_one<span class="o">()</span> <span class="o">{</span></div><div class='line' id='LC28'>&nbsp;&nbsp;<span class="nb">echo </span>2&gt;&amp;1 -n <span class="s2">&quot;$1: &quot;</span></div><div class='line' id='LC29'>&nbsp;&nbsp;vim -e -s -u /dev/null -U /dev/null --noplugin -c <span class="s2">&quot;source import.vim&quot;</span> <span class="se">\</span></div><div class='line' id='LC30'>&nbsp;&nbsp;&nbsp;&nbsp;-c <span class="s2">&quot;$1&quot;</span> -c <span class="s1">&#39;wq! test.go&#39;</span> base.go</div><div class='line' id='LC31'>&nbsp;&nbsp;<span class="c"># ensure blank lines are treated correctly</span></div><div class='line' id='LC32'>&nbsp;&nbsp;<span class="k">if</span> ! gofmt test.go | cmp test.go; <span class="k">then</span></div><div class='line' id='LC33'><span class="k">    </span><span class="nb">echo </span>2&gt;&amp;1 <span class="s2">&quot;gofmt conflict&quot;</span></div><div class='line' id='LC34'>&nbsp;&nbsp;&nbsp;&nbsp;gofmt test.go | diff -u test.go - | sed <span class="s2">&quot;s/^/	/&quot;</span> 2&gt;&amp;1</div><div class='line' id='LC35'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">fail</span><span class="o">=</span>1</div><div class='line' id='LC36'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC37'><span class="k">  fi</span></div><div class='line' id='LC38'><span class="k">  if</span> ! grep -P -q <span class="s2">&quot;(?s)$2&quot;</span> test.go; <span class="k">then</span></div><div class='line' id='LC39'><span class="k">    </span><span class="nb">echo </span>2&gt;&amp;1 <span class="s2">&quot;$2 did not match&quot;</span></div><div class='line' id='LC40'>&nbsp;&nbsp;&nbsp;&nbsp;cat test.go | sed <span class="s2">&quot;s/^/	/&quot;</span> 2&gt;&amp;1</div><div class='line' id='LC41'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">fail</span><span class="o">=</span>1</div><div class='line' id='LC42'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC43'><span class="k">  fi</span></div><div class='line' id='LC44'><span class="k">  </span><span class="nb">echo </span>2&gt;&amp;1 <span class="s2">&quot;ok&quot;</span></div><div class='line' id='LC45'><span class="o">}</span></div><div class='line' id='LC46'><br/></div><div class='line' id='LC47'><span class="c"># Tests for Import</span></div><div class='line' id='LC48'><br/></div><div class='line' id='LC49'>test_one <span class="s2">&quot;Import baz&quot;</span> <span class="s1">&#39;&quot;baz&quot;.*&quot;bytes&quot;&#39;</span></div><div class='line' id='LC50'>test_one <span class="s2">&quot;Import io/ioutil&quot;</span> <span class="s1">&#39;&quot;io&quot;.*&quot;io/ioutil&quot;.*&quot;net&quot;&#39;</span></div><div class='line' id='LC51'>test_one <span class="s2">&quot;Import myc&quot;</span> <span class="s1">&#39;&quot;io&quot;.*&quot;myc&quot;.*&quot;net&quot;&#39;</span>  <span class="c"># prefix of a site prefix</span></div><div class='line' id='LC52'>test_one <span class="s2">&quot;Import nat&quot;</span> <span class="s1">&#39;&quot;io&quot;.*&quot;nat&quot;.*&quot;net&quot;&#39;</span></div><div class='line' id='LC53'>test_one <span class="s2">&quot;Import net/http&quot;</span> <span class="s1">&#39;&quot;net&quot;.*&quot;net/http&quot;.*&quot;mycorp/foo&quot;&#39;</span></div><div class='line' id='LC54'>test_one <span class="s2">&quot;Import zoo&quot;</span> <span class="s1">&#39;&quot;net&quot;.*&quot;zoo&quot;.*&quot;mycorp/foo&quot;&#39;</span></div><div class='line' id='LC55'>test_one <span class="s2">&quot;Import mycorp/bar&quot;</span> <span class="s1">&#39;&quot;net&quot;.*&quot;mycorp/bar&quot;.*&quot;mycorp/foo&quot;&#39;</span></div><div class='line' id='LC56'>test_one <span class="s2">&quot;Import mycorp/goo&quot;</span> <span class="s1">&#39;&quot;net&quot;.*&quot;mycorp/foo&quot;.*&quot;mycorp/goo&quot;&#39;</span></div><div class='line' id='LC57'><br/></div><div class='line' id='LC58'><span class="c"># Tests for Drop</span></div><div class='line' id='LC59'><br/></div><div class='line' id='LC60'>cat &gt; base.go <span class="s">&lt;&lt;EOF</span></div><div class='line' id='LC61'><span class="s">package test</span></div><div class='line' id='LC62'><br/></div><div class='line' id='LC63'><span class="s">import (</span></div><div class='line' id='LC64'><span class="s">	&quot;foo&quot;</span></div><div class='line' id='LC65'><br/></div><div class='line' id='LC66'><span class="s">	&quot;something&quot;</span></div><div class='line' id='LC67'><span class="s">	&quot;zoo&quot;</span></div><div class='line' id='LC68'><span class="s">)</span></div><div class='line' id='LC69'><span class="s">EOF</span></div><div class='line' id='LC70'><br/></div><div class='line' id='LC71'>test_one <span class="s2">&quot;Drop something&quot;</span> <span class="s1">&#39;\([^&quot;]*&quot;foo&quot;[^&quot;]*&quot;zoo&quot;[^&quot;]*\)&#39;</span></div><div class='line' id='LC72'><br/></div><div class='line' id='LC73'>rm -f base.go test.go</div><div class='line' id='LC74'><span class="k">if</span> <span class="o">[</span> <span class="nv">$fail</span> -gt 0 <span class="o">]</span>; <span class="k">then</span></div><div class='line' id='LC75'><span class="k">  </span><span class="nb">echo </span>2&gt;&amp;1 <span class="s2">&quot;FAIL&quot;</span></div><div class='line' id='LC76'>&nbsp;&nbsp;<span class="nb">exit </span>1</div><div class='line' id='LC77'><span class="k">fi</span></div><div class='line' id='LC78'><span class="nb">echo </span>2&gt;&amp;1 <span class="s2">&quot;PASS&quot;</span></div></pre></div>
            </td>
          </tr>
        </table>
  </div>

  </div>
</div>

<a href="#jump-to-line" rel="facebox[.linejump]" data-hotkey="l" class="js-jump-to-line" style="display:none">Jump to Line</a>
<div id="jump-to-line" style="display:none">
  <form accept-charset="UTF-8" class="js-jump-to-line-form">
    <input class="linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" autofocus>
    <button type="submit" class="button">Go</button>
  </form>
</div>

        </div>

      </div><!-- /.repo-container -->
      <div class="modal-backdrop"></div>
    </div><!-- /.container -->
  </div><!-- /.site -->


    </div><!-- /.wrapper -->

      <div class="container">
  <div class="site-footer">
    <ul class="site-footer-links right">
      <li><a href="https://status.github.com/">Status</a></li>
      <li><a href="http://developer.github.com">API</a></li>
      <li><a href="http://training.github.com">Training</a></li>
      <li><a href="http://shop.github.com">Shop</a></li>
      <li><a href="/blog">Blog</a></li>
      <li><a href="/about">About</a></li>

    </ul>

    <a href="/">
      <span class="mega-octicon octicon-mark-github"></span>
    </a>

    <ul class="site-footer-links">
      <li>&copy; 2013 <span title="0.03716s from github-fe115-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="/site/terms">Terms</a></li>
        <li><a href="/site/privacy">Privacy</a></li>
        <li><a href="/security">Security</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
  </div><!-- /.site-footer -->
</div><!-- /.container -->


    <div class="fullscreen-overlay js-fullscreen-overlay" id="fullscreen_overlay">
  <div class="fullscreen-container js-fullscreen-container">
    <div class="textarea-wrap">
      <textarea name="fullscreen-contents" id="fullscreen-contents" class="js-fullscreen-contents" placeholder="" data-suggester="fullscreen_suggester"></textarea>
          <div class="suggester-container">
              <div class="suggester fullscreen-suggester js-navigation-container" id="fullscreen_suggester"
                 data-url="/jnwhiteh/vim-golang/suggestions/commit">
              </div>
          </div>
    </div>
  </div>
  <div class="fullscreen-sidebar">
    <a href="#" class="exit-fullscreen js-exit-fullscreen tooltipped leftwards" title="Exit Zen Mode">
      <span class="mega-octicon octicon-screen-normal"></span>
    </a>
    <a href="#" class="theme-switcher js-theme-switcher tooltipped leftwards"
      title="Switch themes">
      <span class="octicon octicon-color-mode"></span>
    </a>
  </div>
</div>



    <div id="ajax-error-message" class="flash flash-error">
      <span class="octicon octicon-alert"></span>
      <a href="#" class="octicon octicon-remove-close close ajax-error-dismiss"></a>
      Something went wrong with that request. Please try again.
    </div>

    
  </body>
</html>

