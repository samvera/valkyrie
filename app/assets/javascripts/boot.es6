import FileManager from 'file_manager'
export class Initializer {
  constructor() {
    this.file_manager = new FileManager
    this.sortable_placeholder()
  }

  sortable_placeholder() {
    $( "#sortable" ).on( "sortstart", function( event, ui ) {
      let found_element = $("#sortable").find("li[data-reorder-id]").last()
      ui.placeholder.width(found_element.width())
      ui.placeholder.height(found_element.height())
    })
  }
}
