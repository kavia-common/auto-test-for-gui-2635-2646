*** Settings ***
Library    SeleniumLibrary
*** Test Cases ***
Open Data URI And Check Title
    ${url}=    Set Variable    data:text/html,<title>smoke</title><h1>smoke</h1>
    Open Browser    ${url}    browser=chrome    options=add_argument('--headless=new')
    ${title}=    Get Title
    Should Be Equal    ${title}    smoke
    Close Browser
Dummy Desktop Action
    Log    Desktop placeholder; runs only if DESKTOP_AUTOMATION=1
