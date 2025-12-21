# Demo 4 Header Form Overview

## Architecture

```
d4_data_controller.qml      (170 lines) - Pure QField/QGIS API ⭐ WORKSHOP FOCUS
d4_form_controller.qml      (160 lines) - Form coordination logic
d4_widget_accessor.qml       (55 lines) - Widget value abstraction
d4_headerpage.qml (170 lines) - UI presentation only
d4_form_section.qml          (70 lines) - Reusable form section
d4_form_field.qml           (140 lines) - Reusable form field
```

## Component Responsibilities

### 1. d4_data_controller.qml ⭐ **WORKSHOP FOCUS**

**Purpose**: Pure QField/QGIS API interactions - this is what workshop participants learn.

**Key Functions**:
- `loadFeatureForPlot(plotId)` - Feature iteration and creation
- `createNewFeature(plotId)` - Feature creation workflow
- `getFieldValue(fieldName)` - Safe attribute access
- `saveFieldValues(fieldValueMap)` - Layer editing and commits
- `getAllFieldValues()` - Debugging helper

**Demonstrates**:
```qml
// Feature iteration with CRITICAL iterator closing
var iterator = LayerUtils.createFeatureIteratorFromExpression(layer, expression)
if (iterator.hasNext()) {
    currentFeature = iterator.next()
}
iterator.close()  // CRITICAL: Always close!

// Feature creation
var newFeature = FeatureUtils.createFeature(layer)
newFeature.setAttribute("field_name", value)
LayerUtils.addFeature(layer, newFeature)

// Field value access - NEVER hardcode indexes
var value = feature.attribute("field_name")
var fieldIndex = fields.indexOf("field_name")
layer.changeAttributeValue(fid, fieldIndex, value)
```

**NO UI CODE** - can be taught independently and tested in isolation.

### 2. d4_form_controller.qml

**Purpose**: Mediates between data layer and UI widgets.

**Key Functions**:
- `registerWidget(fieldId, accessor)` - Widget registration
- `collectFormValues()` - Gather all widget values
- `populateFormFromFeature(feature)` - Load feature into form
- `save()` - Orchestrate save operation
- `loadPlot(plotId)` - Orchestrate load operation

**Benefits**:
- Decouples data access from widget implementation
- Single place to manage form state
- Easy to add validation or transformation logic

### 3. d4_widget_accessor.qml

**Purpose**: Standardized access to widget values.

**Factory Methods**:
- `createTextAccessor(textEditItem)` - For TextEdit widgets
- `createRangeAccessor(loaderItem)` - For d4_range widgets (handles loader chain)

**Hides**:
- Loader chain navigation (`loader.item.item`)
- Widget-specific API differences
- Type conversion logic

### 4. d4_headerpage_refactored.qml

**Purpose**: UI presentation and layout only.

**Structure**:
```qml
Page {
    // Controllers instantiation
    d4_data_controller { id: dataController }
    d4_form_controller { id: formController }
    d4_widget_accessor { id: widgetAccessor }
    
    // UI layout - just Rectangle, Column, Repeater
    Rectangle {
        Column {
            Text { } // Title
            Rectangle { } // Save button
            Repeater { // Form sections
                delegate: FormSection { }
            }
        }
    }
    
    // Public API
    function setPlotId(plotId) {
        formController.loadPlot(plotId)
    }
}
```

**Benefits**:
- Easy to understand UI structure
- No QField API calls visible
- Declarative bindings to controller state

### 5. d4_form_section.qml

**Purpose**: Reusable component for a group of fields.

**Props**:
- `sectionData` - From data model (title, fields array)
- `formController` - For widget registration
- `widgetAccessor` - For creating accessors

**Layout**: Title + Flow layout of fields

### 6. d4_form_field.qml

**Purpose**: Self-registering form field component.

**Features**:
- Automatically determines field type (text vs numeric)
- Auto-registers with form controller on completion
- Handles TextEdit or d4_range widget creation
- Marks form as changed on user input

## Workshop Teaching Flow

### Step 1: Understand Data Model (existing)
```qml
// d4_form_data_model.qml
readonly property var fields: [
    { id: "comment", label: "Comments", fieldType: "text" },
    { id: "t1_cover", label: "1. Canopy", stepSize: 5 }
]
```

### Step 2: Study Data Controller ⭐ FOCUS HERE
```qml
// Pure QField API - no UI complexity
dataController.loadFeatureForPlot("ABC123")
dataController.saveFieldValues({ "t1_cover": 75, "comment": "Dense" })
```

**Workshop exercises**:
1. Add a new field to data model
2. Observe how data controller handles it automatically
3. Add debugging console.log to trace feature lifecycle
4. Experiment with queries (filter by different fields)

### Step 3: Observe Form Controller
```qml
// Coordinates between data and UI
formController.loadPlot("ABC123")  // Calls dataController + populates widgets
formController.save()              // Collects widgets + calls dataController
```

### Step 4: UI Layer (brief overview)
```qml
// Just presentation - can be customized without touching data logic
Repeater {
    model: formDataModel.groupBoxes
    delegate: FormSection { }
}
```