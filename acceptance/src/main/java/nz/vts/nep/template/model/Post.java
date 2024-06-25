/* Copyright Vector Technology Services LTD - All Rights Reserved
 *
 * Unauthorized copying of this file or derived binaries, via any medium, is strictly prohibited unless express written
 * consent is given
 *
 * All content is deemed proprietary and confidential
 *
 * Contact Vector LTD legal at "legalservices@vector.co.nz" for more information or to report a breach
 */
package nz.vts.nep.template.model;

public class Post {

    private String id;
    private String title;
    private String author;
    private String url;
    private String content;
    private String ups;
    private String downs;

    public Post(
            String id,
            String title,
            String author,
            String url,
            String content,
            String ups,
            String downs
    ) {
        this.id = id;
        this.title = title;
        this.author = author;
        this.url = url;
        this.content = content;
        this.ups = ups;
        this.downs = downs;
    }

    public String getId() {
        return id;
    }

    public void setId(
            String id
    ) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(
            String title
    ) {
        this.title = title;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(
            String author
    ) {
        this.author = author;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(
            String url
    ) {
        this.url = url;
    }

    public String getContent() {
        return content;
    }

    public void setContent(
            String content
    ) {
        this.content = content;
    }

    public String getUps() {
        return ups;
    }

    public void setUps(
            String ups
    ) {
        this.ups = ups;
    }

    public String getDowns() {
        return downs;
    }

    public void setDowns(
            String downs
    ) {
        this.downs = downs;
    }
}
