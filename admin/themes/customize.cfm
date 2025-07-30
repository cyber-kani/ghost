<!--- Theme Customization Page --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.theme" default="">
<cfparam name="form.submitted" default="false">

<!--- Validate theme parameter --->
<cfif NOT len(url.theme)>
    <cflocation url="index.cfm" addtoken="false">
</cfif>

<!--- Check theme exists --->
<cfset themePath = expandPath("/ghost/themes/#url.theme#/")>
<cfif NOT directoryExists(themePath) OR NOT fileExists("#themePath#theme.json")>
    <cflocation url="index.cfm" addtoken="false">
</cfif>

<!--- Read theme configuration --->
<cfset themeJson = fileRead("#themePath#theme.json")>
<cfset themeInfo = deserializeJSON(themeJson)>

<!--- Get current theme settings --->
<cfquery name="qThemeSettings" datasource="#request.dsn#">
    SELECT `key`, value FROM settings WHERE `key` LIKE 'theme_%'
</cfquery>

<cfset currentSettings = {}>
<cfloop query="qThemeSettings">
    <cfset cleanKey = replace(qThemeSettings.key, "theme_", "")>
    <cfset currentSettings[cleanKey] = qThemeSettings.value>
</cfloop>

<!--- Process form submission --->
<cfif form.submitted EQ "true">
    <cftry>
        <!--- Save theme settings --->
        <cfloop collection="#themeInfo.options#" item="optionKey">
            <cfset option = themeInfo.options[optionKey]>
            <cfset formValue = structKeyExists(form, optionKey) ? form[optionKey] : option.default>
            
            <!--- Handle boolean values --->
            <cfif option.type EQ "boolean">
                <cfset formValue = structKeyExists(form, optionKey) ? "true" : "false">
            </cfif>
            
            <!--- Check if setting exists --->
            <cfquery name="qExistingSetting" datasource="#request.dsn#">
                SELECT id FROM settings
                WHERE `key` = <cfqueryparam value="theme_#optionKey#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif qExistingSetting.recordCount GT 0>
                <!--- Update existing setting --->
                <cfquery datasource="#request.dsn#">
                    UPDATE settings
                    SET value = <cfqueryparam value="#formValue#" cfsqltype="cf_sql_varchar">,
                        updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                        updated_by = <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_varchar">
                    WHERE `key` = <cfqueryparam value="theme_#optionKey#" cfsqltype="cf_sql_varchar">
                </cfquery>
            <cfelse>
                <!--- Insert new setting --->
                <cfset settingId = lcase(left(replace(createUUID(), "-", "", "all"), 24))>
                <cfquery datasource="#request.dsn#">
                    INSERT INTO settings (id, `key`, value, type, created_at, created_by, updated_at, updated_by)
                    VALUES (
                        <cfqueryparam value="#settingId#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="theme_#optionKey#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#formValue#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="theme" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                        <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                        <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_varchar">
                    )
                </cfquery>
            </cfif>
        </cfloop>
        
        <cfset successMessage = "Theme settings saved successfully">
    <cfcatch>
        <cfset errorMessage = "Error saving theme settings: #cfcatch.message#">
    </cfcatch>
    </cftry>
</cfif>

<cfset pageTitle = "Customize #themeInfo.name#">
<cfinclude template="../includes/header.cfm">

<div class="gh-canvas">
    <header class="gh-canvas-header">
        <h2 class="gh-canvas-title">Customize <cfoutput>#themeInfo.name#</cfoutput></h2>
        <section class="view-actions">
            <a class="gh-btn" href="index.cfm">
                <span>Back to themes</span>
            </a>
        </section>
    </header>

    <section class="view-container">
        <cfif structKeyExists(variables, "successMessage")>
            <div class="gh-alert gh-alert-green">
                <cfoutput>#successMessage#</cfoutput>
            </div>
        </cfif>
        
        <cfif structKeyExists(variables, "errorMessage")>
            <div class="gh-alert gh-alert-red">
                <cfoutput>#errorMessage#</cfoutput>
            </div>
        </cfif>
        
        <form method="post" class="gh-editor">
            <input type="hidden" name="submitted" value="true">
            
            <div class="gh-main">
                <section class="gh-editor-feature-image">
                    <div class="gh-editor-feature-image-container">
                        <h3>Theme Settings</h3>
                        <p>Customize the appearance and behavior of the <cfoutput>#themeInfo.name#</cfoutput> theme.</p>
                    </div>
                </section>
                
                <div class="gh-editor-wordcount-container">
                    <div class="gh-editor-wordcount">
                        <cfloop collection="#themeInfo.options#" item="optionKey">
                            <cfset option = themeInfo.options[optionKey]>
                            <cfset currentValue = structKeyExists(currentSettings, optionKey) ? currentSettings[optionKey] : option.default>
                            
                            <div class="form-group">
                                <label for="<cfoutput>#optionKey#</cfoutput>">
                                    <cfoutput>#option.label#</cfoutput>
                                </label>
                                
                                <cfif option.type EQ "color">
                                    <input type="color" 
                                           id="<cfoutput>#optionKey#</cfoutput>" 
                                           name="<cfoutput>#optionKey#</cfoutput>" 
                                           value="<cfoutput>#currentValue#</cfoutput>"
                                           class="gh-input color-input">
                                           
                                <cfelseif option.type EQ "select">
                                    <select id="<cfoutput>#optionKey#</cfoutput>" 
                                            name="<cfoutput>#optionKey#</cfoutput>" 
                                            class="gh-input">
                                        <cfloop array="#option.options#" index="selectOption">
                                            <option value="<cfoutput>#selectOption.value#</cfoutput>" 
                                                    <cfif currentValue EQ selectOption.value>selected</cfif>>
                                                <cfoutput>#selectOption.label#</cfoutput>
                                            </option>
                                        </cfloop>
                                    </select>
                                    
                                <cfelseif option.type EQ "boolean">
                                    <label class="switch">
                                        <input type="checkbox" 
                                               id="<cfoutput>#optionKey#</cfoutput>" 
                                               name="<cfoutput>#optionKey#</cfoutput>" 
                                               value="true"
                                               <cfif currentValue EQ "true">checked</cfif>>
                                        <span class="slider round"></span>
                                    </label>
                                    
                                <cfelse>
                                    <input type="text" 
                                           id="<cfoutput>#optionKey#</cfoutput>" 
                                           name="<cfoutput>#optionKey#</cfoutput>" 
                                           value="<cfoutput>#currentValue#</cfoutput>"
                                           class="gh-input">
                                </cfif>
                            </div>
                        </cfloop>
                    </div>
                </div>
            </div>
            
            <footer class="gh-editor-footer">
                <button type="submit" class="gh-btn gh-btn-primary gh-btn-icon">
                    <span>Save settings</span>
                </button>
            </footer>
        </form>
    </section>
</div>

<style>
.form-group {
    margin-bottom: 2rem;
}

.form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 600;
    color: var(--darkgrey);
}

.gh-input {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid var(--whitegrey-l2);
    border-radius: 4px;
    font-size: 1.5rem;
    line-height: 1.5;
    font-weight: 300;
    color: var(--darkgrey);
    background: var(--white);
    transition: border-color 0.15s linear;
}

.gh-input:focus {
    outline: none;
    border-color: var(--blue);
}

.color-input {
    width: 80px;
    height: 40px;
    padding: 4px;
    cursor: pointer;
}

/* Toggle Switch */
.switch {
    position: relative;
    display: inline-block;
    width: 50px;
    height: 28px;
}

.switch input {
    opacity: 0;
    width: 0;
    height: 0;
}

.slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #ccc;
    transition: .4s;
}

.slider:before {
    position: absolute;
    content: "";
    height: 20px;
    width: 20px;
    left: 4px;
    bottom: 4px;
    background-color: white;
    transition: .4s;
}

input:checked + .slider {
    background-color: var(--green);
}

input:focus + .slider {
    box-shadow: 0 0 1px var(--green);
}

input:checked + .slider:before {
    transform: translateX(22px);
}

.slider.round {
    border-radius: 34px;
}

.slider.round:before {
    border-radius: 50%;
}

.gh-alert {
    margin-bottom: 2rem;
    padding: 1.2rem 2rem;
    border-radius: 4px;
    font-size: 1.4rem;
    line-height: 1.5;
}

.gh-alert-green {
    background: rgba(48, 207, 67, 0.1);
    color: var(--green);
    border: 1px solid rgba(48, 207, 67, 0.3);
}

.gh-alert-red {
    background: rgba(240, 82, 48, 0.1);
    color: var(--red);
    border: 1px solid rgba(240, 82, 48, 0.3);
}
</style>

<cfinclude template="../includes/footer.cfm">